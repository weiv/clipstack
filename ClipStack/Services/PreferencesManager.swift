import SwiftUI
import ServiceManagement
import Cocoa

enum HotKeyModifierCombo: String, CaseIterable, Identifiable {
    case commandOption = "commandOption"
    case commandShift = "commandShift"
    case controlOption = "controlOption"
    case controlShift = "controlShift"
    case commandControl = "commandControl"

    var id: String { rawValue }

    var modifierFlags: NSEvent.ModifierFlags {
        switch self {
        case .commandOption: return [.command, .option]
        case .commandShift: return [.command, .shift]
        case .controlOption: return [.control, .option]
        case .controlShift: return [.control, .shift]
        case .commandControl: return [.command, .control]
        }
    }

    var displayName: String {
        switch self {
        case .commandOption: return "⌘⌥"
        case .commandShift: return "⌘⇧"
        case .controlOption: return "⌃⌥"
        case .controlShift: return "⌃⇧"
        case .commandControl: return "⌘⌃"
        }
    }

    var fullDisplayName: String {
        switch self {
        case .commandOption: return "Command+Option"
        case .commandShift: return "Command+Shift"
        case .controlOption: return "Control+Option"
        case .controlShift: return "Control+Shift"
        case .commandControl: return "Command+Control"
        }
    }
}

final class PreferencesManager: ObservableObject {
    static let shared = PreferencesManager()

    @AppStorage("launchAtLogin") var launchAtLogin: Bool = false {
        didSet { applyLaunchAtLogin() }
    }

    @AppStorage("hotKeyModifiers") private var hotKeyModifiersRaw: String = "commandOption" {
        didSet { applyHotKeyModifiers() }
    }

    var hotKeyModifiers: HotKeyModifierCombo {
        get { HotKeyModifierCombo(rawValue: hotKeyModifiersRaw) ?? .commandOption }
        set { hotKeyModifiersRaw = newValue.rawValue }
    }

    private init() {
        // Sync with system state on init
        if #available(macOS 13.0, *) {
            let isEnabled = SMAppService.mainApp.status == .enabled
            if isEnabled != launchAtLogin {
                launchAtLogin = isEnabled
            }
        }
    }

    private func applyLaunchAtLogin() {
        if #available(macOS 13.0, *) {
            do {
                if launchAtLogin {
                    try SMAppService.mainApp.register()
                } else {
                    try SMAppService.mainApp.unregister()
                }
            } catch {
                NSLog("ClipStack: Failed to set launch at login: \(error)")
                // Reconcile state with actual system state
                let actualState = SMAppService.mainApp.status == .enabled
                launchAtLogin = actualState
            }
        }
    }

    private func applyHotKeyModifiers() {
        NotificationCenter.default.post(
            name: NSNotification.Name("HotKeyModifiersDidChange"),
            object: hotKeyModifiers.modifierFlags
        )
    }
}
