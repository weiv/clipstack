# Changelog

All notable changes to ClipStack will be documented in this file.

## [0.1.0] - 2026-02-12

### Added
- Initial release of ClipStack
- Menu bar clipboard history manager (stores last 10 items)
- Click-to-paste from menu bar
- Global keyboard shortcuts to paste items 1-10 with customizable modifiers
  - 5 modifier combinations available: ⌘⌥, ⌘⇧, ⌃⌥, ⌃⇧, ⌘⌃
  - Default: Command+Option
  - Configurable in Preferences
- Launch at Login toggle
- Preferences window with ESC key support to close
- Clear History option
- Homebrew tap for easy installation (`brew tap weiv/clipstack && brew install clipstack`)
- Full unit test coverage (44 tests)

### Technical
- Built with SwiftUI + MenuBarExtra (macOS 13+)
- Non-sandboxed for CGEvent paste simulation
- Precise clipboard change tracking (eliminates race conditions)
- Idempotent timer-based clipboard monitoring
- Accessibility permission handling with graceful fallbacks
- ServiceManagement integration for Launch at Login
- Responsive preferences UI with Picker for modifier selection
