# TODO

**Status**: P0 reliability issues ✅ complete. Ready for P1 core functionality features.

## P0 - Reliability / correctness first ✅

All P0 items complete as of Feb 12, 2026. These fixes ensure the app behaves correctly under all conditions:

- [x] Replace time-based `PasteService.isOwnChange` skip logic with a more precise own-write tracker
  - Changed from 600ms timeout to exact pasteboard `changeCount` tracking
  - Eliminates race condition where user clipboard entries could be dropped
- [x] Make `ClipboardMonitor.start()` idempotent (prevent multiple timers)
  - Guards against creating multiple timers if `start()` called repeatedly
  - Prevents clipboard monitoring duplication
- [x] Reconcile Launch at Login toggle state after register/unregister failures
  - Syncs UI state with actual system state if ServiceManagement operations fail
  - Prevents confusing UI state mismatches
- [x] Improve Accessibility permission flow (avoid repeated prompts; add clear status/next step in UI)
  - Prompts only once, then provides clear instructions for users who deny
  - Makes it clear why paste simulation isn't working

## P1 - Core functionality

Essential features for a usable clipboard manager:

- [ ] Persist clipboard history to disk (survive app restarts)
  - Currently stored only in memory; lost on app restart
  - Consider JSON or SQLite format in ~/Library/Application Support/MacClip/
- [x] Settings window infrastructure (Launch at Login implemented)
  - [x] Launch at Login toggle (with ServiceManagement)
  - [ ] Configurable history size UI (preference model ready in PreferencesManager)
  - [ ] Configurable polling interval UI (preference model ready in PreferencesManager)
  - [ ] Keyboard shortcut configuration UI (needs key capture component)
- [ ] Configurable history size (currently fixed at 10)
  - PreferencesManager has `historySize` property ready
  - Need to update ClipboardHistory to respect the preference
- [ ] Configurable keyboard shortcuts
  - Currently hardcoded Control+Option+1-0
  - Need UI for capturing and storing custom shortcuts
  - HotKeyManager needs to dynamically register shortcuts
- [ ] Search/filter history items (type to filter in menu)
  - Add text field at top of menu
  - Filter items in real-time as user types

## P2 - Clipboard type support

Extend beyond text-only clipboard management:

- [ ] Handle pasteboard types beyond `.string` (URLs, file paths)
  - Check for NSPasteboard.PasteboardType.URL
  - Check for NSPasteboard.PasteboardType.fileURL
  - Store type info in ClipboardItem for display purposes
- [ ] Support images and file paths, not just text
  - Add image thumbnail preview in menu
  - Show file paths with icon
  - Requires different storage (images too large for memory)
- [ ] Rich text support (preserve formatting)
  - Detect NSPasteboard.PasteboardType.rtf or .html
  - Store formatted text; paste back in original format
  - Challenge: displaying RTF in menu (plain text only?)
- [ ] Reduce polling interval or use NSPasteboard observation if available
  - Current: 0.5s polling is inefficient
  - NSPasteboard doesn't have change notifications
  - Consider UIPasteboard observation (iOS-style) if available on current macOS
  - Could use FSEvents or other mechanisms

## P3 - Product features / UX

Polish and advanced features for competitive clipboard manager:

- [ ] Pin frequently used items so they don't get pushed out
  - Add star/pin icon in menu
  - Pinned items stay at top, don't age out
- [ ] Snippet manager - save named reusable text snippets
  - Like Alfred snippets: save templates with {{variables}}
  - Separate from clipboard history
- [ ] Shortcut that displays a popup menu with latest few items that can be clicked on to paste
  - Already partially implemented (Control+Option+0 shows popup menu)
  - Enhance with larger preview and better interaction
- [ ] Timestamp display (e.g. "2 min ago") on each item
  - Add relative time helper function
  - Display in menu or preview tooltip
- [ ] Preview tooltip on hover for long items
  - Show full text in tooltip for items > 80 chars
  - Use NSToolTip or custom NSPopover
- [ ] Notification sound or visual feedback on paste
  - Brief "pasted" notification in bottom corner
  - Optional sound effect on settings
- [ ] Drag and drop items to reorder or paste
  - Drag item to other app to paste
  - Reorder within history (if persisted to disk)
- [ ] Custom app icon
  - Current: default app icon
  - Design menu bar-appropriate icon (simple, monochrome)
- [ ] Dark/light mode-aware styling
  - Menus should respect system appearance
  - Use NSAppearance for detection
- [ ] Ability to add a control to control center
  - macOS 13.1+ Control Center integration
  - Quick access without menu bar click

## P4 - Distribution / ops

Setup for real-world usage and distribution:

- [x] Unit tests for ClipboardHistory model
- [ ] Sparkle framework for auto-updates
  - Add SPM dependency: sparkle-project/Sparkle
  - Generate public/private keys for update signing
  - Set up update feed on web server
- [ ] DMG or Homebrew Cask distribution
  - Create DMG with nice installer
  - Or: submit to Homebrew Casks for `brew install macclip`
- [ ] Code signing with Developer ID for distribution outside App Store
  - Get Apple Developer ID certificate
  - Sign app bundle with `codesign` command
  - Notarize with Apple (required for first-run)
- [ ] Memory usage profiling for long-running sessions
  - Monitor memory growth over time
  - Consider weak references if keeping large text items
  - Profile with Instruments (Allocations tool)
