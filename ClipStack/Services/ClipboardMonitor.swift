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

        guard let text = pasteboard.string(forType: .string) else { return }

        DispatchQueue.main.async { [weak self] in
            self?.history.add(text)
        }
    }
}
