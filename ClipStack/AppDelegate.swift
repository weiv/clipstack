import Cocoa

final class AppDelegate: NSObject, NSApplicationDelegate {
    private var clipboardMonitor: ClipboardMonitor?
    private var hotKeyManager: HotKeyManager?
    private var preferencesObserver: NSObjectProtocol?

    func applicationDidFinishLaunching(_ notification: Notification) {
        PermissionService.checkAccessibility()

        // Initialize preferences
        _ = PreferencesManager.shared

        clipboardMonitor = ClipboardMonitor()
        clipboardMonitor?.start()

        hotKeyManager = HotKeyManager()
        let modifiers = PreferencesManager.shared.hotKeyModifiers.modifierFlags
        hotKeyManager?.register(modifiers: modifiers)

        // Listen for preference changes
        preferencesObserver = NotificationCenter.default.addObserver(
            forName: NSNotification.Name("HotKeyModifiersDidChange"),
            object: nil,
            queue: .main
        ) { [weak self] notification in
            if let modifiers = notification.object as? NSEvent.ModifierFlags {
                self?.hotKeyManager?.updateModifiers(modifiers)
            }
        }
    }

    func applicationWillTerminate(_ notification: Notification) {
        if let observer = preferencesObserver {
            NotificationCenter.default.removeObserver(observer)
        }
        clipboardMonitor?.stop()
        hotKeyManager?.unregister()
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        // Only hide from Dock if there's no preferences window open
        if SettingsOpener.preferencesWindow == nil {
            DispatchQueue.main.async {
                NSApp.setActivationPolicy(.accessory)
                NSApp.deactivate()
            }
        }
        return false
    }
}
