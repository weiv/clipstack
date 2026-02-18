import Cocoa

final class ClipboardMonitor {
    private var timer: Timer?
    private var lastChangeCount: Int

    private let history: ClipboardHistory

    init(history: ClipboardHistory = .shared) {
        self.history = history
        self.lastChangeCount = NSPasteboard.general.changeCount
    }

    func start() {
        guard timer == nil else { return }
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
            self?.checkPasteboard()
        }
    }

    func stop() {
        timer?.invalidate()
        timer = nil
    }

    private func checkPasteboard() {
        let pasteboard = NSPasteboard.general
        let currentCount = pasteboard.changeCount

        guard currentCount != lastChangeCount else { return }
        lastChangeCount = currentCount

        // Skip if this was our own paste operation
        if let skipCount = PasteService.skipNextChangeCount, currentCount == skipCount {
            PasteService.skipNextChangeCount = nil
            return
        }

        guard let content = ClipboardMonitor.readContent(from: pasteboard) else { return }

        DispatchQueue.main.async { [weak self] in
            self?.history.add(content)
        }
    }

    static func readContent(from pasteboard: NSPasteboard) -> ClipboardContent? {
        // 1. Image — TIFF first
        if let tiffData = pasteboard.data(forType: .tiff) {
            let thumbnail = makeThumbnail(from: tiffData)
            return .image(tiffData: tiffData, thumbnail: thumbnail)
        }

        // PNG fallback: read PNG, convert to TIFF
        if let pngData = pasteboard.data(forType: NSPasteboard.PasteboardType("public.png")),
           let image = NSImage(data: pngData),
           let tiffData = image.tiffRepresentation {
            let thumbnail = makeThumbnail(from: tiffData)
            return .image(tiffData: tiffData, thumbnail: thumbnail)
        }

        // 2. File URL
        if let urls = pasteboard.readObjects(
            forClasses: [NSURL.self],
            options: [.urlReadingFileURLsOnly: true]
        ) as? [URL], !urls.isEmpty {
            return .fileURL(urls)
        }

        // 3. Rich Text
        if let rtfData = pasteboard.data(forType: .rtf),
           let attributed = NSAttributedString(rtf: rtfData, documentAttributes: nil) {
            return .richText(rtfData: rtfData, plainFallback: attributed.string)
        }

        // 4. String — classify as webURL or plainText
        guard let string = pasteboard.string(forType: .string) else { return nil }

        if let url = URL(string: string),
           let scheme = url.scheme,
           (scheme == "http" || scheme == "https"),
           url.host != nil {
            return .webURL(url)
        }

        return .plainText(string)
    }

    private static func makeThumbnail(from tiffData: Data) -> NSImage {
        guard let source = NSImage(data: tiffData) else {
            return NSImage()
        }
        let maxHeight: CGFloat = 18
        let maxWidth: CGFloat = 80
        let size = source.size
        guard size.height > 0, size.width > 0 else { return source }

        let heightScale = maxHeight / size.height
        let widthScale = maxWidth / size.width
        let scale = min(heightScale, widthScale, 1.0)
        let newSize = NSSize(width: size.width * scale, height: size.height * scale)

        let thumbnail = NSImage(size: newSize)
        thumbnail.lockFocus()
        source.draw(
            in: NSRect(origin: .zero, size: newSize),
            from: NSRect(origin: .zero, size: size),
            operation: .copy,
            fraction: 1.0
        )
        thumbnail.unlockFocus()
        return thumbnail
    }
}
