# TODO

## Features

- [ ] Persist clipboard history to disk (survive app restarts)
- [ ] Support images and file paths, not just text
- [ ] Search/filter history items (type to filter in menu)
- [ ] Pin frequently used items so they don't get pushed out
- [ ] Configurable history size (currently fixed at 10)
- [ ] Configurable keyboard shortcuts
- [ ] Snippet manager — save named reusable text snippets
- [ ] Rich text support (preserve formatting)
- [ ] Preview tooltip on hover for long items
- [ ] Notification sound or visual feedback on paste

## UI/UX

- [ ] Custom app icon
- [ ] Timestamp display (e.g. "2 min ago") on each item
- [ ] Dark/light mode-aware styling
- [ ] Drag and drop items to reorder or paste
- [ ] Settings window (history size, polling interval, shortcuts)
- [ ] Onboarding flow explaining Accessibility permission

## Technical

- [ ] Unit tests for ClipboardHistory model
- [ ] Reduce polling interval or use NSPasteboard observation if available
- [ ] Sparkle framework for auto-updates
- [ ] DMG or Homebrew Cask distribution
- [ ] Code signing with Developer ID for distribution outside App Store
- [ ] Handle pasteboard types beyond `.string` (URLs, file paths)
- [ ] Memory usage profiling for long-running sessions
