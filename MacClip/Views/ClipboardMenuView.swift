import SwiftUI

struct ClipboardMenuView: View {
    @ObservedObject var history = ClipboardHistory.shared

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
                        if index < 9 {
                            Text("⌘⇧\(index + 1)")
                                .foregroundColor(.secondary)
                        } else if index == 9 {
                            Text("⌘⇧0")
                                .foregroundColor(.secondary)
                        }
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

        Button("Quit MacClip") {
            NSApplication.shared.terminate(nil)
        }
        .keyboardShortcut("q")
    }
}
