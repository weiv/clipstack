import SwiftUI

struct PreferencesView: View {
    @ObservedObject var preferences = PreferencesManager.shared

    var body: some View {
        Form {
            Section("General") {
                Toggle("Launch at Login", isOn: $preferences.launchAtLogin)
            }

            Section("History") {
                Picker("History Size:", selection: $preferences.historySize) {
                    ForEach([5, 10, 15, 20, 25, 50], id: \.self) { size in
                        Text("\(size) items").tag(size)
                    }
                }
                .pickerStyle(.menu)
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

            Section("Clipboard Monitoring") {
                Picker("Check Frequency:", selection: $preferences.pollingInterval) {
                    Text("Very Fast (0.25s)").tag(0.25)
                    Text("Fast (0.5s)").tag(0.5)
                    Text("Normal (1s)").tag(1.0)
                    Text("Slow (2s)").tag(2.0)
                }
                .pickerStyle(.menu)

                Text("How often ClipStack checks for clipboard changes")
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
