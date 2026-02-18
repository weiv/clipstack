import Cocoa
import HotKey
import Carbon.HIToolbox

final class HotKeyManager {
    private var hotKeys: [HotKey] = []
    private let history: ClipboardHistory

    init(history: ClipboardHistory = .shared) {
        self.history = history
    }

    func register(modifiers: NSEvent.ModifierFlags = [.command, .option],
                  plainTextModifiers: NSEvent.ModifierFlags = [.command, .option, .shift]) {
        unregister()  // Clear existing first

        // Map 1 through 0 to history indices 0-9
        // Keys 1-9 map to indices 0-8, key 0 maps to index 9
        let keyMappings: [(Key, Int)] = [
            (.one, 0),
            (.two, 1),
            (.three, 2),
            (.four, 3),
            (.five, 4),
            (.six, 5),
            (.seven, 6),
            (.eight, 7),
            (.nine, 8),
            (.zero, 9),
        ]

        for (key, index) in keyMappings {
            let hk = HotKey(key: key, modifiers: modifiers)
            hk.keyDownHandler = { [weak self] in
                guard let self else { return }
                if let item = self.history.item(at: index) {
                    PasteService.paste(item)
                }
            }
            hotKeys.append(hk)

            let plainHk = HotKey(key: key, modifiers: plainTextModifiers)
            plainHk.keyDownHandler = { [weak self] in
                guard let self else { return }
                if let item = self.history.item(at: index) {
                    PasteService.pastePlain(item)
                }
            }
            hotKeys.append(plainHk)
        }
    }

    func updateModifiers(_ modifiers: NSEvent.ModifierFlags) {
        let prefs = PreferencesManager.shared
        register(modifiers: modifiers,
                 plainTextModifiers: prefs.hotKeyModifiers.plainTextModifierFlags)
    }

    func unregister() {
        hotKeys.removeAll()
    }
}
