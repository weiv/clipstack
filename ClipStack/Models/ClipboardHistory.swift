import Foundation

final class ClipboardHistory: ObservableObject {

    static let shared: ClipboardHistory = {
        let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let dir = appSupport.appendingPathComponent("ClipStack")
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return ClipboardHistory(storageURL: dir.appendingPathComponent("history.json"))
    }()

    private static let defaultMaxItems = 10
    private let storageURL: URL?

    var maxItems: Int {
        didSet {
            if items.count > maxItems {
                items = Array(items.prefix(maxItems))
                save()
            }
        }
    }

    @Published private(set) var items: [ClipboardItem] = []

    /// Pass `storageURL: nil` to create an in-memory-only instance (used by tests).
    init(maxItems: Int = defaultMaxItems, storageURL: URL? = nil) {
        self.maxItems = maxItems
        self.storageURL = storageURL
        load()
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
        save()
    }

    func item(at index: Int) -> ClipboardItem? {
        guard index >= 0, index < items.count else { return nil }
        return items[index]
    }

    func clear() {
        items.removeAll()
        save()
    }

    // MARK: - Persistence

    private func load() {
        guard let url = storageURL,
              let data = try? Data(contentsOf: url),
              let decoded = try? JSONDecoder().decode([ClipboardItem].self, from: data)
        else { return }
        items = Array(decoded.prefix(maxItems))
    }

    private func save() {
        guard let url = storageURL else { return }
        // Images are excluded from persistence (can be tens of MB each)
        let saveable = items.filter { if case .image = $0.content { return false }; return true }
        if let data = try? JSONEncoder().encode(saveable) {
            try? data.write(to: url, options: .atomic)
        }
    }
}
