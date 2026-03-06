import Foundation

struct PokemonData: Codable, Identifiable, Hashable {
    let name: String
    let gen: Int

    var id: String { name }

    var isCustom: Bool { gen == -1 }

    var displayName: String {
        guard let first = name.first else { return name }
        return first.uppercased() + name.dropFirst()
    }

    var genLabel: String {
        isCustom ? "Custom" : "Gen \(gen)"
    }
}
