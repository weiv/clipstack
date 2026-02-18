import SwiftUI
import AppKit
import Sparkle

struct ClipboardMenuView: View {
    @ObservedObject var history = ClipboardHistory.shared
    @ObservedObject var preferences = PreferencesManager.shared
    let updater: SPUUpdater?

    var body: some View {
        if history.items.isEmpty {
            Text("No clipboard history")
                .foregroundColor(.secondary)
        } else {
            ForEach(Array(history.items.enumerated()), id: \.element.id) { index, item in
                let key: Character = index < 9 ? Character("\(index + 1)") : "0"
                Button(action: {
                    PasteService.paste(item)
                }) {
                    contentLabel(for: item.content, timestamp: relativeTime(item.copiedAt))
                }
                .help(tooltipText(for: item.content))
                .keyboardShortcut(KeyEquivalent(key), modifiers: preferences.hotKeyModifiers.eventModifiers)
            }
        }

        Divider()

        Button("Clear History") {
            history.clear()
        }
        .disabled(history.items.isEmpty)

        Divider()

        Button("Check for Updates...") {
            updater?.checkForUpdates()
        }
        .disabled(updater?.canCheckForUpdates == false)

        Button("About ClipStack") {
            SettingsOpener.openAbout()
        }

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

    private func relativeTime(_ date: Date) -> String {
        let seconds = Int(Date().timeIntervalSince(date))
        switch seconds {
        case ..<60:     return "just now"
        case ..<3600:   return "\(seconds / 60)m ago"
        case ..<86400:  return "\(seconds / 3600)h ago"
        case ..<604800: return "\(seconds / 86400)d ago"
        default:
            let f = DateFormatter()
            f.dateFormat = "MMM d"
            return f.string(from: date)
        }
    }

    private func tooltipText(for content: ClipboardContent) -> String {
        switch content {
        case .plainText(let s):          return s
        case .webURL(let url):           return url.absoluteString
        case .fileURL(let urls):         return urls.map(\.path).joined(separator: "\n")
        case .richText(_, let fallback): return fallback
        case .image:                     return "Image"
        }
    }

    /// Truncates primary text and appends a dimmed timestamp using Text concatenation —
    /// a single Text view that renders correctly in .menu MenuBarExtra.
    private func rowText(_ primary: String, timestamp: String, color: Color = .primary) -> Text {
        let truncated = primary.count > 45 ? String(primary.prefix(45)) + "…" : primary
        return Text(truncated).foregroundColor(color)
            + Text("  \(timestamp)").font(.caption).foregroundColor(.secondary)
    }

    @ViewBuilder
    private func contentLabel(for content: ClipboardContent, timestamp: String) -> some View {
        switch content {
        case .plainText(let s):
            Label {
                rowText(s.trimmingCharacters(in: .whitespacesAndNewlines), timestamp: timestamp)
            } icon: {
                Image(systemName: content.typeIcon)
            }
        case .richText(_, let fallback):
            Label {
                rowText(fallback.trimmingCharacters(in: .whitespacesAndNewlines), timestamp: timestamp)
            } icon: {
                Image(systemName: content.typeIcon)
            }
        case .webURL(let url):
            Label {
                rowText(url.absoluteString, timestamp: timestamp, color: .blue)
            } icon: {
                Image(systemName: content.typeIcon)
                    .foregroundColor(.blue)
            }
        case .fileURL(let urls):
            Label {
                rowText(urls.map { $0.lastPathComponent }.joined(separator: ", "), timestamp: timestamp)
            } icon: {
                if let first = urls.first {
                    Image(nsImage: NSWorkspace.shared.icon(forFile: first.path))
                        .resizable()
                        .frame(width: 16, height: 16)
                }
            }
        case .image(_, let thumbnail):
            Label {
                rowText("Image", timestamp: timestamp, color: .secondary)
            } icon: {
                Image(nsImage: thumbnail)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 16)
            }
        }
    }
}
