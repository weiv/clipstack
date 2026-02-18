import SwiftUI
import AppKit

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
                    PasteService.paste(item)
                }) {
                    HStack {
                        contentLabel(for: item.content)
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

    @ViewBuilder
    private func contentLabel(for content: ClipboardContent) -> some View {
        switch content {
        case .plainText(let s):
            Label {
                Text(s.trimmingCharacters(in: .whitespacesAndNewlines))
                    .lineLimit(1)
            } icon: {
                Image(systemName: content.typeIcon)
            }
        case .richText(_, let fallback):
            Label {
                Text(fallback.trimmingCharacters(in: .whitespacesAndNewlines))
                    .lineLimit(1)
            } icon: {
                Image(systemName: content.typeIcon)
            }
        case .webURL(let url):
            Label {
                Text(url.absoluteString)
                    .lineLimit(1)
                    .foregroundColor(.blue)
            } icon: {
                Image(systemName: content.typeIcon)
                    .foregroundColor(.blue)
            }
        case .fileURL(let urls):
            HStack {
                if let first = urls.first {
                    Image(nsImage: NSWorkspace.shared.icon(forFile: first.path))
                        .resizable()
                        .frame(width: 16, height: 16)
                }
                Text(urls.map { $0.lastPathComponent }.joined(separator: ", "))
                    .lineLimit(1)
            }
        case .image(_, let thumbnail):
            HStack {
                Image(nsImage: thumbnail)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 16)
                Text("Image")
                    .foregroundColor(.secondary)
            }
        }
    }
}
