import Cocoa
import SwiftUI

class PreferencesWindowController: NSWindowController, NSWindowDelegate {
    convenience init() {
        let hostingController = NSHostingController(rootView: PreferencesView())
        let window = NSWindow(contentViewController: hostingController)
        window.title = "Preferences"
        window.setFrameAutosaveName("PreferencesWindow")
        self.init(window: window)
        self.window?.delegate = self
    }

    func windowWillClose(_ notification: Notification) {
        // Clear the reference so AppDelegate knows to hide from Dock
        SettingsOpener.preferencesWindow = nil
    }
}

struct SettingsOpener {
    static var preferencesWindow: PreferencesWindowController?

    static func openSettings() {
        NSApp.setActivationPolicy(.regular)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            NSApp.activate(ignoringOtherApps: true)

            // Close existing preferences window if open
            if let existingWindow = preferencesWindow {
                existingWindow.close()
            }

            // Create and show new preferences window
            preferencesWindow = PreferencesWindowController()
            preferencesWindow?.showWindow(nil)
            preferencesWindow?.window?.makeKeyAndOrderFront(nil)
        }
    }
}
