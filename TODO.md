# TODO

## P0 - Reliability / correctness first

- [x] Replace time-based `PasteService.isOwnChange` skip logic with a more precise own-write tracker (avoid dropping real user clipboard changes)
- [x] Make `ClipboardMonitor.start()` idempotent (prevent multiple timers)
- [x] Reconcile Launch at Login toggle state after register/unregister failures
- [x] Improve Accessibility permission flow (avoid repeated prompts; add clear status/next step in UI)

## P1 - Core functionality

- [ ] Persist clipboard history to disk (survive app restarts)
- [x] Settings window infrastructure (Launch at Login implemented)
  - [x] Launch at Login toggle (with ServiceManagement)
  - [ ] Configurable history size UI (preference model ready)
  - [ ] Configurable polling interval UI (preference model ready)
  - [ ] Keyboard shortcut configuration UI
- [ ] Configurable history size (currently fixed at 10)
- [ ] Configurable keyboard shortcuts
- [ ] Search/filter history items (type to filter in menu)

## P2 - Clipboard type support

- [ ] Handle pasteboard types beyond `.string` (URLs, file paths)
- [ ] Support images and file paths, not just text
- [ ] Rich text support (preserve formatting)
- [ ] Reduce polling interval or use NSPasteboard observation if available

## P3 - Product features / UX

- [ ] Pin frequently used items so they don't get pushed out
- [ ] Snippet manager - save named reusable text snippets
- [ ] Shortcut that displays a popup menu with latest few items that can be clicked on to paste
- [ ] Timestamp display (e.g. "2 min ago") on each item
- [ ] Preview tooltip on hover for long items
- [ ] Notification sound or visual feedback on paste
- [ ] Drag and drop items to reorder or paste
- [ ] Custom app icon
- [ ] Dark/light mode-aware styling
- [ ] Ability to add a control to control center

## P4 - Distribution / ops

- [x] Unit tests for ClipboardHistory model
- [ ] Sparkle framework for auto-updates
- [ ] DMG or Homebrew Cask distribution
- [ ] Code signing with Developer ID for distribution outside App Store
- [ ] Memory usage profiling for long-running sessions
