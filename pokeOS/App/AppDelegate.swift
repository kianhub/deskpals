import AppKit

class AppDelegate: NSObject, NSApplicationDelegate {
    var overlayWindow: OverlayWindow?

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSAppleEventManager.shared().setEventHandler(
            self,
            andSelector: #selector(handleURLEvent(_:withReply:)),
            forEventClass: AEEventClass(kInternetEventClass),
            andEventID: AEEventID(kAEGetURL)
        )

        let settings = AppSettings.shared
        let frame = NSRect(
            x: settings.rectX,
            y: settings.rectY,
            width: settings.rectWidth,
            height: settings.rectHeight
        )
        overlayWindow = OverlayWindow(contentRect: frame)
        if settings.isVisible {
            overlayWindow?.makeKeyAndOrderFront(nil)
        }
    }

    @objc private func handleURLEvent(_ event: NSAppleEventDescriptor, withReply reply: NSAppleEventDescriptor) {
        guard let urlString = event.paramDescriptor(forKeyword: keyDirectObject)?.stringValue,
              let url = URL(string: urlString),
              url.scheme == "pokeos",
              let host = url.host else {
            return
        }

        let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        let queryItems = components?.queryItems ?? []
        let settings = AppSettings.shared

        switch host {
        case "pokemon":
            if let name = queryItems.first(where: { $0.name == "name" })?.value {
                settings.selectedPokemon = name
            }
            if let genString = queryItems.first(where: { $0.name == "gen" })?.value,
               let gen = Int(genString) {
                settings.selectedPokemonGen = gen
            }
            if let shinyString = queryItems.first(where: { $0.name == "shiny" })?.value {
                settings.isShiny = (shinyString == "true")
            }

        case "toggle":
            settings.isVisible.toggle()

        case "resize":
            if let widthString = queryItems.first(where: { $0.name == "width" })?.value,
               let width = Double(widthString) {
                settings.rectWidth = width
            }
            if let heightString = queryItems.first(where: { $0.name == "height" })?.value,
               let height = Double(heightString) {
                settings.rectHeight = height
            }

        case "move":
            if let xString = queryItems.first(where: { $0.name == "x" })?.value,
               let x = Double(xString) {
                settings.rectX = x
            }
            if let yString = queryItems.first(where: { $0.name == "y" })?.value,
               let y = Double(yString) {
                settings.rectY = y
            }

        default:
            break
        }
    }
}
