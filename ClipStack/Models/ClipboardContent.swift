import Cocoa

enum ClipboardContent: Equatable {
    case plainText(String)
    case webURL(URL)
    case fileURL([URL])
    case richText(rtfData: Data, plainFallback: String)
    case image(tiffData: Data, thumbnail: NSImage)

    var displayText: String {
        switch self {
        case .plainText(let s):
            let trimmed = s.trimmingCharacters(in: .whitespacesAndNewlines)
            if trimmed.count > 80 {
                return String(trimmed.prefix(80)) + "..."
            }
            return trimmed
        case .webURL(let url):
            return url.absoluteString
        case .fileURL(let urls):
            return urls.map { $0.lastPathComponent }.joined(separator: ", ")
        case .richText(_, let fallback):
            let trimmed = fallback.trimmingCharacters(in: .whitespacesAndNewlines)
            if trimmed.count > 80 {
                return String(trimmed.prefix(80)) + "..."
            }
            return trimmed
        case .image:
            return "Image"
        }
    }

    var typeIcon: String {
        switch self {
        case .plainText: return "doc.text"
        case .webURL: return "link"
        case .fileURL: return "doc"
        case .richText: return "doc.richtext"
        case .image: return "photo"
        }
    }

    static func == (lhs: ClipboardContent, rhs: ClipboardContent) -> Bool {
        switch (lhs, rhs) {
        case (.plainText(let a), .plainText(let b)): return a == b
        case (.webURL(let a), .webURL(let b)): return a == b
        case (.fileURL(let a), .fileURL(let b)): return a == b
        case (.richText(let aData, _), .richText(let bData, _)): return aData == bData
        case (.image(let aData, _), .image(let bData, _)): return aData == bData
        default: return false
        }
    }
}
