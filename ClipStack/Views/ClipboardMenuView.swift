import SwiftUI

struct ClipboardMenuView: View {
    @ObservedObject var history = ClipboardHistory.shared
    @ObservedObject var preferences = PreferencesManager.shared

    var body: some View {
        if history.items.isEmpty {
            Text("No clipboard history")
                .foregroundColor(.secondary)
        } else {
            ForEach(Array(history.items.enumerated()), id: \.element.id) { index, item in
                Button(action: {
                    PasteService.paste(item.text)
                }) {
                    HStack {
                        Text(item.displayText)
                            .lineLimit(1)
                        Spacer()
                        let keyNumber = index < 9 ? index + 1 : 0
                        Text("\(preferences.hotKeyModifiers.displayName)\(keyNumber)")
                            .foregroundColor(.secondary)
                    }
                }
            }
        }

        Divider()

        Button("Clear History") {
            history.clear()
        }
        .disabled(history.items.isEmpty)

        Divider()

        Button("Preferences...") {
            SettingsOpener.openSettings()
        }
        .keyboardShortcut(",", modifiers: .command)

        Divider()

        Button("Quit ClipStack") {
            NSApplication.shared.terminate(nil)
        }
        .keyboardShortcut("q")
    }
}
