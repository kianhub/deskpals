import AppKit

struct SpriteLoader {
    static func loadSprite(name: String, gen: Int, isShiny: Bool, isWalking: Bool) -> NSImage? {
        let variant = isShiny ? "shiny" : "default"
        let state = isWalking ? "walk" : "idle"
        let fileName = "\(variant)_\(state)_8fps"
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
        guard let url = Bundle.main.url(forResource: "pokemon", withExtension: "json") else {
            return []
        }

        guard let data = try? Data(contentsOf: url),
              let list = try? JSONDecoder().decode([PokemonData].self, from: data) else {
            return []
        }

        return list
    }
}
