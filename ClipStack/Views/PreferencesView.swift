import SwiftUI

struct PreferencesView: View {
    @ObservedObject var preferences = PreferencesManager.shared

    var body: some View {
        Form {
            Section("General") {
                Toggle("Launch at Login", isOn: $preferences.launchAtLogin)
            }

            Section("Keyboard Shortcuts") {
                Picker("Modifier Keys:", selection: $preferences.hotKeyModifiers) {
                    ForEach(HotKeyModifierCombo.allCases) { combo in
                        Text(combo.fullDisplayName).tag(combo)
                    }
                }
                .pickerStyle(.radioGroup)

                Text("Press \(preferences.hotKeyModifiers.displayName)+1 through \(preferences.hotKeyModifiers.displayName)+0 to paste history items")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .formStyle(.grouped)
        .frame(width: 400, height: 400)
        .padding()
    }
}

#Preview {
    PreferencesView()
}
