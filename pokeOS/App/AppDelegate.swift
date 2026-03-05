import AppKit

class AppDelegate: NSObject, NSApplicationDelegate {
    var overlayWindow: OverlayWindow?

    func applicationDidFinishLaunching(_ notification: Notification) {
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
}
