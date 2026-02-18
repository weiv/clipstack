import Foundation

struct ClipboardItem: Identifiable, Equatable, Codable {
    let id: UUID
    let content: ClipboardContent
    let copiedAt: Date

    init(content: ClipboardContent, copiedAt: Date = Date()) {
        self.id = UUID()
        self.content = content
        self.copiedAt = copiedAt
    }

    // Used by Codable to restore a persisted item with its original id
    private init(id: UUID, content: ClipboardContent, copiedAt: Date) {
        self.id = id
        self.content = content
        self.copiedAt = copiedAt
    }

    var displayText: String {
        content.displayText
    }

    static func == (lhs: ClipboardItem, rhs: ClipboardItem) -> Bool {
        lhs.content == rhs.content
    }

    // MARK: - Codable

    private enum CodingKeys: String, CodingKey {
        case id, content, copiedAt
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(content, forKey: .content)
        try container.encode(copiedAt, forKey: .copiedAt)
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let id = try container.decode(UUID.self, forKey: .id)
        let content = try container.decode(ClipboardContent.self, forKey: .content)
        let copiedAt = try container.decode(Date.self, forKey: .copiedAt)
        self.init(id: id, content: content, copiedAt: copiedAt)
    }
}
