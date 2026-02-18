import Foundation

final class ClipboardHistory: ObservableObject {
    static let shared = ClipboardHistory()
    private static let defaultMaxItems = 10

    var maxItems: Int {
        didSet {
            if items.count > maxItems {
                items = Array(items.prefix(maxItems))
            }
        }
    }

    @Published private(set) var items: [ClipboardItem] = []

    init(maxItems: Int = defaultMaxItems) {
        self.maxItems = maxItems
    }

    func add(_ content: ClipboardContent) {
        // For plain text, reject empty/whitespace-only
        if case .plainText(let s) = content {
            guard !s.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        }

        // Remove duplicate if exists (move to top)
        items.removeAll { $0.content == content }

        let item = ClipboardItem(content: content, copiedAt: Date())
        items.insert(item, at: 0)

        if items.count > maxItems {
            items = Array(items.prefix(maxItems))
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
