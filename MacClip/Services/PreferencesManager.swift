import SwiftUI
import ServiceManagement

final class PreferencesManager: ObservableObject {
    static let shared = PreferencesManager()

    @AppStorage("launchAtLogin") var launchAtLogin: Bool = false {
        didSet { applyLaunchAtLogin() }
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
                NSLog("MacClip: Failed to set launch at login: \(error)")
                // Reconcile state with actual system state
                let actualState = SMAppService.mainApp.status == .enabled
                launchAtLogin = actualState
            }
        }
    }
}
