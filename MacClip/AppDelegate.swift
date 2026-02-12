import Cocoa

final class AppDelegate: NSObject, NSApplicationDelegate {
    private var clipboardMonitor: ClipboardMonitor?
    private var hotKeyManager: HotKeyManager?

    func applicationDidFinishLaunching(_ notification: Notification) {
        PermissionService.checkAccessibility()

        // Initialize preferences
        _ = PreferencesManager.shared

        clipboardMonitor = ClipboardMonitor()
        clipboardMonitor?.start()

        hotKeyManager = HotKeyManager()
        hotKeyManager?.register()
    }

    func applicationWillTerminate(_ notification: Notification) {
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
