import Foundation

final class ClipboardHistory: ObservableObject {
    static let shared = ClipboardHistory()
    private static let maxItems = 10

    @Published private(set) var items: [ClipboardItem] = []

    init() {}

    func add(_ content: ClipboardContent) {
        // For plain text, reject empty/whitespace-only
        if case .plainText(let s) = content {
            guard !s.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        }

        // Remove duplicate if exists (move to top)
        items.removeAll { $0.content == content }

        let item = ClipboardItem(content: content, copiedAt: Date())
        items.insert(item, at: 0)

        // Keep only the most recent items
        if items.count > Self.maxItems {
            items = Array(items.prefix(Self.maxItems))
        }
    }

    func item(at index: Int) -> ClipboardItem? {
        guard index >= 0, index < items.count else { return nil }
        return items[index]
    }

    func clear() {
        items.removeAll()
    }
}
