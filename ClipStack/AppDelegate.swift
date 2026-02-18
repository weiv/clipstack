import Cocoa
import Sparkle

final class AppDelegate: NSObject, NSApplicationDelegate {
    private var clipboardMonitor: ClipboardMonitor?
    private var hotKeyManager: HotKeyManager?
    private var observers: [NSObjectProtocol] = []
    let updaterController = SPUStandardUpdaterController(
        startingUpdater: true,
        updaterDelegate: nil,
        userDriverDelegate: nil
    )

    func applicationDidFinishLaunching(_ notification: Notification) {
        PermissionService.checkAccessibility()

        // Initialize preferences
        _ = PreferencesManager.shared

        let prefs = PreferencesManager.shared
        ClipboardHistory.shared.maxItems = prefs.historySize

        clipboardMonitor = ClipboardMonitor(interval: prefs.pollingInterval)
        clipboardMonitor?.start()

        hotKeyManager = HotKeyManager()
        hotKeyManager?.register(modifiers: prefs.hotKeyModifiers.modifierFlags,
                                plainTextModifiers: prefs.hotKeyModifiers.plainTextModifierFlags)

        // Listen for preference changes
        let nc = NotificationCenter.default
        observers.append(nc.addObserver(
            forName: NSNotification.Name("HotKeyModifiersDidChange"),
            object: nil, queue: .main
        ) { [weak self] notification in
            if let modifiers = notification.object as? NSEvent.ModifierFlags {
                self?.hotKeyManager?.updateModifiers(modifiers)
            }
        })
        observers.append(nc.addObserver(
            forName: NSNotification.Name("HistorySizeDidChange"),
            object: nil, queue: .main
        ) { notification in
            if let size = notification.object as? Int {
                ClipboardHistory.shared.maxItems = size
            }
        })
        observers.append(nc.addObserver(
            forName: NSNotification.Name("PollingIntervalDidChange"),
            object: nil, queue: .main
        ) { [weak self] notification in
            if let interval = notification.object as? Double {
                self?.clipboardMonitor?.updateInterval(interval)
            }
        })
    }

    func applicationWillTerminate(_ notification: Notification) {
        observers.forEach { NotificationCenter.default.removeObserver($0) }
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
