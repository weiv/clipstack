import Cocoa
import SwiftUI

class PreferencesWindowController: NSWindowController, NSWindowDelegate {
    convenience init() {
        let hostingController = NSHostingController(rootView: PreferencesView())
        let window = PreferencesWindow(contentViewController: hostingController)
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

// Custom NSWindow to handle ESC key
class PreferencesWindow: NSWindow {
    override func keyDown(with event: NSEvent) {
        if event.keyCode == 53 {  // ESC key
            self.close()
        } else {
            super.keyDown(with: event)
        }
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
