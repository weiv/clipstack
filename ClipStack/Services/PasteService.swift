import Cocoa
import Carbon.HIToolbox

enum PasteService {
    /// Track the next expected pasteboard change count from our own paste operation.
    /// This is more reliable than a time-based flag.
    static var skipNextChangeCount: Int?

    static func paste(_ item: ClipboardItem) {
        let pasteboard = NSPasteboard.general

        // Store the change count that will occur after our write
        let currentCount = pasteboard.changeCount
        skipNextChangeCount = currentCount + 1

        pasteboard.clearContents()
        writeContent(item.content, to: pasteboard)

        // Delay to allow the menu to close and the previous app to regain focus
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            simulateCmdV()
            PasteHUD.shared.show()
        }
    }

    static func pastePlain(_ item: ClipboardItem) {
        guard let text = item.content.plainText else { return }
        let pasteboard = NSPasteboard.general
        let currentCount = pasteboard.changeCount
        skipNextChangeCount = currentCount + 1
        pasteboard.clearContents()
        pasteboard.setString(text, forType: .string)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            simulateCmdV()
            PasteHUD.shared.show()
        }
    }

    private static func writeContent(_ content: ClipboardContent, to pasteboard: NSPasteboard) {
        switch content {
        case .plainText(let s):
            pasteboard.setString(s, forType: .string)
        case .webURL(let url):
            pasteboard.setString(url.absoluteString, forType: .string)
        case .fileURL(let urls):
            pasteboard.writeObjects(urls as [NSURL])
        case .richText(let data, _):
            pasteboard.setData(data, forType: .rtf)
        case .image(let data, _):
            pasteboard.setData(data, forType: .tiff)
        }
    }

    private static func simulateCmdV() {
        let source = CGEventSource(stateID: .hidSystemState)

        let keyDown = CGEvent(keyboardEventSource: source, virtualKey: CGKeyCode(kVK_ANSI_V), keyDown: true)
        keyDown?.flags = .maskCommand

        let keyUp = CGEvent(keyboardEventSource: source, virtualKey: CGKeyCode(kVK_ANSI_V), keyDown: false)
        keyUp?.flags = .maskCommand

        keyDown?.post(tap: .cghidEventTap)
        keyUp?.post(tap: .cghidEventTap)
    }
}
