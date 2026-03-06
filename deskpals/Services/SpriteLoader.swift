import AppKit

struct SpriteLoader {
    /// Custom sprites live in ~/Library/Application Support/deskpals/CustomSprites/{name}/
    static let customSpritesDirectory: URL = {
        let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        return appSupport.appendingPathComponent("deskpals/CustomSprites", isDirectory: true)
    }()

    static func loadSprite(name: String, gen: Int, isShiny: Bool, isWalking: Bool) -> NSImage? {
        let variant = isShiny ? "shiny" : "default"
        let state = isWalking ? "walk" : "idle"
        let fileName = "\(variant)_\(state)_8fps"

        // 1) Check custom sprites folder first (gen == -1 means custom, but check for all)
        let customDir = customSpritesDirectory.appendingPathComponent(name, isDirectory: true)
        let customFile = customDir.appendingPathComponent("\(fileName).gif")
        if FileManager.default.fileExists(atPath: customFile.path),
           let data = try? Data(contentsOf: customFile) {
            return NSImage(data: data)
        }

        // For custom sprites, fall back: shiny -> default, walk -> idle
        if gen == -1 {
            let fallbackFile = customDir.appendingPathComponent("default_\(state)_8fps.gif")
            if FileManager.default.fileExists(atPath: fallbackFile.path),
               let data = try? Data(contentsOf: fallbackFile) {
                return NSImage(data: data)
            }
            let idleFallback = customDir.appendingPathComponent("default_idle_8fps.gif")
            if FileManager.default.fileExists(atPath: idleFallback.path),
               let data = try? Data(contentsOf: idleFallback) {
                return NSImage(data: data)
            }
            return nil
        }

        // 2) Fall back to bundled sprites
        let subdirectory = "Sprites/gen\(gen)/\(name)"
        guard let url = Bundle.main.url(forResource: fileName, withExtension: "gif", subdirectory: subdirectory) else {
            return nil
        }
        guard let data = try? Data(contentsOf: url) else {
            return nil
        }
        return NSImage(data: data)
    }

    static func loadPokemonList() -> [PokemonData] {
        var list: [PokemonData] = []

        // Load bundled Pokemon
        if let url = Bundle.main.url(forResource: "pokemon", withExtension: "json"),
           let data = try? Data(contentsOf: url),
           let bundled = try? JSONDecoder().decode([PokemonData].self, from: data) {
            list = bundled
        }

        // Discover custom sprites
        list.append(contentsOf: discoverCustomSprites())

        return list
    }

    /// Scans the CustomSprites directory for valid sprite folders.
    /// A valid folder must contain at least default_idle_8fps.gif.
    static func discoverCustomSprites() -> [PokemonData] {
        let fm = FileManager.default
        let dir = customSpritesDirectory

        guard fm.fileExists(atPath: dir.path),
              let entries = try? fm.contentsOfDirectory(at: dir, includingPropertiesForKeys: [.isDirectoryKey]) else {
            return []
        }

        var customs: [PokemonData] = []
        for entry in entries {
            guard (try? entry.resourceValues(forKeys: [.isDirectoryKey]))?.isDirectory == true else { continue }
            let idleFile = entry.appendingPathComponent("default_idle_8fps.gif")
            guard fm.fileExists(atPath: idleFile.path) else { continue }
            let name = entry.lastPathComponent.lowercased()
            customs.append(PokemonData(name: name, gen: -1))
        }

        return customs.sorted { $0.name < $1.name }
    }

    /// Creates the CustomSprites directory if it doesn't exist, and returns its URL.
    @discardableResult
    static func ensureCustomSpritesDirectory() -> URL {
        let fm = FileManager.default
        if !fm.fileExists(atPath: customSpritesDirectory.path) {
            try? fm.createDirectory(at: customSpritesDirectory, withIntermediateDirectories: true)
        }
        return customSpritesDirectory
    }
}
