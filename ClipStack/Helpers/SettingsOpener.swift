import Cocoa
import SwiftUI

class PreferencesWindowController: NSWindowController, NSWindowDelegate {
    convenience init() {
        let hostingController = NSHostingController(rootView: PreferencesView())
        hostingController.sizingOptions = [.preferredContentSize]
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

class AboutWindowDelegate: NSObject, NSWindowDelegate {
    static let shared = AboutWindowDelegate()

    func windowWillClose(_ notification: Notification) {
        SettingsOpener.aboutWindow = nil
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
    static var aboutWindow: NSWindowController?

    static func openAbout() {
        NSApp.setActivationPolicy(.regular)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            NSApp.activate(ignoringOtherApps: true)

            if let existing = aboutWindow {
                existing.window?.makeKeyAndOrderFront(nil)
                return
            }

            let hostingController = NSHostingController(rootView: AboutView())
            hostingController.sizingOptions = [.preferredContentSize]
            let window = PreferencesWindow(contentViewController: hostingController)
            window.title = "About ClipStack"
            window.styleMask.remove(.resizable)
            let controller = NSWindowController(window: window)
            controller.window?.delegate = AboutWindowDelegate.shared
            aboutWindow = controller
            controller.showWindow(nil)
            window.makeKeyAndOrderFront(nil)
        }
    }

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
