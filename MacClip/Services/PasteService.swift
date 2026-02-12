import Cocoa
import Carbon.HIToolbox

enum PasteService {
    /// Track the next expected pasteboard change count from our own paste operation.
    /// This is more reliable than a time-based flag.
    static var skipNextChangeCount: Int?

    static func paste(_ text: String) {
        let pasteboard = NSPasteboard.general

        // Store the change count that will occur after our write
        let currentCount = pasteboard.changeCount
        skipNextChangeCount = currentCount + 1

        // Write the text to the system pasteboard
        pasteboard.clearContents()
        pasteboard.setString(text, forType: .string)

        // Delay to allow the menu to close and the previous app to regain focus
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            simulateCmdV()
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
