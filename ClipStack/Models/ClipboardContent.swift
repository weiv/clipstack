import Cocoa

enum ClipboardContent: Equatable, Codable {
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

    // MARK: - Codable

    private enum CodingKeys: String, CodingKey {
        case type, text, url, urls, rtfData, plainFallback
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .plainText(let s):
            try container.encode("plainText", forKey: .type)
            try container.encode(s, forKey: .text)
        case .webURL(let url):
            try container.encode("webURL", forKey: .type)
            try container.encode(url.absoluteString, forKey: .url)
        case .fileURL(let urls):
            try container.encode("fileURL", forKey: .type)
            try container.encode(urls.map { $0.absoluteString }, forKey: .urls)
        case .richText(let data, let fallback):
            try container.encode("richText", forKey: .type)
            try container.encode(data, forKey: .rtfData)
            try container.encode(fallback, forKey: .plainFallback)
        case .image:
            throw EncodingError.invalidValue(self, .init(
                codingPath: encoder.codingPath,
                debugDescription: "Images are not persisted to disk"
            ))
        }
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(String.self, forKey: .type)
        switch type {
        case "plainText":
            self = .plainText(try container.decode(String.self, forKey: .text))
        case "webURL":
            let s = try container.decode(String.self, forKey: .url)
            guard let url = URL(string: s) else {
                throw DecodingError.dataCorruptedError(forKey: .url, in: container,
                    debugDescription: "Invalid URL: \(s)")
            }
            self = .webURL(url)
        case "fileURL":
            let strings = try container.decode([String].self, forKey: .urls)
            self = .fileURL(strings.compactMap { URL(string: $0) })
        case "richText":
            self = .richText(
                rtfData: try container.decode(Data.self, forKey: .rtfData),
                plainFallback: try container.decode(String.self, forKey: .plainFallback)
            )
        default:
            throw DecodingError.dataCorruptedError(forKey: .type, in: container,
                debugDescription: "Unknown content type: \(type)")
        }
    }

    // MARK: - Equatable

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
