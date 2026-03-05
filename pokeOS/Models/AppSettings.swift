import Foundation
import Combine

class AppSettings: ObservableObject {
    static let shared = AppSettings()

    @Published var selectedPokemon: String {
        didSet { UserDefaults.standard.set(selectedPokemon, forKey: "selectedPokemon") }
    }
    @Published var selectedPokemonGen: Int {
        didSet { UserDefaults.standard.set(selectedPokemonGen, forKey: "selectedPokemonGen") }
    }
    @Published var isShiny: Bool {
        didSet { UserDefaults.standard.set(isShiny, forKey: "isShiny") }
    }
    @Published var rectWidth: Double {
        didSet { UserDefaults.standard.set(rectWidth, forKey: "rectWidth") }
    }
    @Published var rectHeight: Double {
        didSet { UserDefaults.standard.set(rectHeight, forKey: "rectHeight") }
    }
    @Published var rectX: Double {
        didSet { UserDefaults.standard.set(rectX, forKey: "rectX") }
    }
    @Published var rectY: Double {
        didSet { UserDefaults.standard.set(rectY, forKey: "rectY") }
    }
    @Published var isVisible: Bool {
        didSet { UserDefaults.standard.set(isVisible, forKey: "isVisible") }
    }
    @Published var spriteScale: Double {
        didSet { UserDefaults.standard.set(spriteScale, forKey: "spriteScale") }
    }
    @Published var launchAtLogin: Bool {
        didSet { UserDefaults.standard.set(launchAtLogin, forKey: "launchAtLogin") }
    }

    private init() {
        let defaults = UserDefaults.standard

        defaults.register(defaults: [
            "selectedPokemon": "pikachu",
            "selectedPokemonGen": 1,
            "isShiny": false,
            "rectWidth": 400.0,
            "rectHeight": 300.0,
            "rectX": 100.0,
            "rectY": 100.0,
            "isVisible": true,
            "spriteScale": 2.0,
            "launchAtLogin": false
        ])

        self.selectedPokemon = defaults.string(forKey: "selectedPokemon") ?? "pikachu"
        self.selectedPokemonGen = defaults.integer(forKey: "selectedPokemonGen") == 0 ? 1 : defaults.integer(forKey: "selectedPokemonGen")
        self.isShiny = defaults.bool(forKey: "isShiny")
        self.rectWidth = defaults.double(forKey: "rectWidth")
        self.rectHeight = defaults.double(forKey: "rectHeight")
        self.rectX = defaults.double(forKey: "rectX")
        self.rectY = defaults.double(forKey: "rectY")
        self.isVisible = defaults.object(forKey: "isVisible") == nil ? true : defaults.bool(forKey: "isVisible")
        self.spriteScale = defaults.double(forKey: "spriteScale") == 0 ? 2.0 : defaults.double(forKey: "spriteScale")
        self.launchAtLogin = defaults.bool(forKey: "launchAtLogin")
    }
}
