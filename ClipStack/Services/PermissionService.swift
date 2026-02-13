import Cocoa
import ApplicationServices

enum PermissionService {
    // Track whether we've already prompted to avoid repeated prompts
    private static var hasPrompted = false

    static func checkAccessibility() {
        // First check without prompting to see current status
        guard !isAccessibilityEnabled() else { return }

        // If not enabled and we haven't prompted yet, request permission
        if !hasPrompted {
            hasPrompted = true
            promptForAccessibility()
        } else {
            // Already prompted but still not enabled - log helpful message
            logAccessibilityRequired()
        }
    }

    private static func isAccessibilityEnabled() -> Bool {
        let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue(): false] as CFDictionary
        return AXIsProcessTrustedWithOptions(options)
    }

    private static func promptForAccessibility() {
        let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue(): true] as CFDictionary
        let _ = AXIsProcessTrustedWithOptions(options)
    }

    private static func logAccessibilityRequired() {
        NSLog("""
        ClipStack: Accessibility permission is required for paste simulation to work.
        To enable it:
        1. Open System Settings > Privacy & Security > Accessibility
        2. Click the lock to make changes
        3. Add ClipStack to the list of allowed apps
        4. Restart ClipStack
        """)
    }
}
