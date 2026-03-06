import SwiftUI

@main
struct pokeOSApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        MenuBarExtra {
            MenuBarContentView(settings: AppSettings.shared)
        } label: {
            Image(systemName: "circle.fill")
        }
        .menuBarExtraStyle(.window)
    }
}
