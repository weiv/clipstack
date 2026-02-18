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

- [x] Persist clipboard history to disk (survive app restarts)
  - JSON in ~/Library/Application Support/ClipStack/history.json
  - ClipboardContent + ClipboardItem are Codable; images excluded (too large)
  - ClipboardHistory.shared uses real storage URL; test instances use nil (no I/O)
  - 95 tests passing
- [x] Settings window infrastructure
  - [x] Launch at Login toggle (with ServiceManagement)
  - [x] Keyboard shortcut modifier selection (Command+Option, Command+Shift, Control+Option, etc.)
  - [x] ESC key to close preferences window
  - [x] Configurable history size UI (5, 10, 15, 20, 25, 50 items)
  - [x] Configurable polling interval UI (0.25s / 0.5s / 1s / 2s)
- [x] Configurable history size (currently fixed at 10)
  - ClipboardHistory.maxItems is now dynamic; trims live when reduced
- [x] Configurable keyboard shortcuts (modifier keys only)
  - [x] User can select from 5 common modifier combinations
  - [x] Number keys (1-0) remain fixed
  - Future: allow fully custom key bindings
- [ ] Search/filter history items (type to filter in menu)
  - Add text field at top of menu
  - Filter items in real-time as user types

## P2 - Clipboard type support ✅

Extend beyond text-only clipboard management:

- [x] Handle pasteboard types beyond `.string` (URLs, file paths)
  - ClipboardContent enum: plainText, webURL, fileURL, richText, image
  - Detection priority: image → fileURL → RTF → string (web URL or plain)
- [x] Support images and file paths, not just text
  - Image thumbnail preview in menu (max 18pt height, 80pt width)
  - File paths show real Finder icon + filename
  - Full-fidelity paste: TIFF/RTF/fileURL written back to pasteboard natively
- [x] Rich text support (preserve formatting)
  - Detects .rtf pasteboard type; stores RTF data + plain fallback
  - Pastes back original RTF data (preserves formatting in target app)
- [x] Web URL detection
  - http/https strings with valid host classified as .webURL
  - Displayed in blue with link icon
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
  - Already partially implemented (Command+Option+0 shows popup menu)
  - Enhance with larger preview and better interaction
- [x] Timestamp display (e.g. "2 min ago") on each item
  - `relativeTime(_:)` helper: just now / Xm ago / Xh ago / Xd ago / MMM d
  - Rendered inline via `Text + Text` concatenation (secondary color, caption font)
  - Items truncated to 45 chars to keep menu compact
- [x] Preview tooltip on hover for long items
  - `.help(tooltipText(for:))` on each Button shows full text/URL/path on hover
- [ ] Notification sound or visual feedback on paste
  - Brief "pasted" notification in bottom corner
  - Optional sound effect on settings
- [ ] Drag and drop items to reorder or paste
  - Drag item to other app to paste
  - Reorder within history (if persisted to disk)
- [x] Custom app icon
  - [x] Design menu bar-appropriate icon (stacked papers design, teal/blue)
  - [x] Add 1024×1024 PNG to Assets.xcassets
  - [x] Xcode auto-scales to all required macOS sizes
- [ ] Dark/light mode-aware styling
  - Menus should respect system appearance
  - Use NSAppearance for detection
- [ ] Ability to add a control to control center
  - macOS 13.1+ Control Center integration
  - Quick access without menu bar click

## P4 - Distribution / ops

Setup for real-world usage and distribution:

### v0.1.0 Complete ✅

- [x] Unit tests for ClipboardHistory model (44 tests)
- [x] Homebrew Cask distribution
  - [x] Create custom tap: homebrew-clipstack
  - [x] Create cask formula with SHA256
  - [x] Users can install: `brew tap weiv/clipstack && brew install clipstack`
- [x] Release v0.1.0 to GitHub
  - [x] Build Release configuration
  - [x] Create DMG (533 KB)
  - [x] Create GitHub release with notes
  - [x] Add CHANGELOG.md

### v0.1.1 Complete ✅

- [x] Add app icon
  - [x] Design stacked papers icon (teal/blue gradient)
  - [x] Add to Xcode Assets.xcassets
  - [x] Rename Xcode project to ClipStack (from MacClip)
- [x] Release v0.1.1 to GitHub
  - [x] Build Release configuration with new icon
  - [x] Create DMG
  - [x] Create GitHub release v0.1.1
  - [x] Update Homebrew cask formula (version 0.1.1, new SHA256)

### v0.1.2 Complete ✅

- [x] Multi-type clipboard support (P2)
  - [x] `ClipboardContent` enum: plainText, webURL, fileURL, richText, image
  - [x] Full-fidelity paste for all content types
  - [x] Image thumbnails, Finder icons, link color in menu
  - [x] 88 tests passing
- [x] Release v0.1.2 to GitHub
  - [x] Build Release configuration
  - [x] Create DMG
  - [x] Create GitHub release with notes
  - [x] Update Homebrew cask formula (version 0.1.2, new SHA256)

### v0.1.3 Complete ✅

- [x] Timestamps on menu items (relative time, Text+Text concatenation)
- [x] Persist history to disk (JSON, images excluded)
- [x] Hover tooltips (.help() modifier)
- [x] Item truncation (45 chars in menu)
- [x] Configurable history size + polling interval UI
- [x] Release v0.1.3 to GitHub
- [x] Update Homebrew cask formula (version 0.1.3, new SHA256)

### Next Steps

- [ ] Code signing with Developer ID (required for production distribution)
  - Obtain Apple Developer ID certificate
  - Sign Release build: `codesign --deep --force --verify --verbose --sign "Developer ID Application" ClipStack.app`
  - Notarize with Apple: `xcrun notarytool submit ClipStack.dmg --apple-id user@example.com`
  - This ensures no "unidentified developer" warning on first launch

- [ ] Submit to Homebrew Core (optional, increases discoverability)
  - Fork https://github.com/Homebrew/homebrew-casks
  - Add cask to `Casks/c/clipstack.rb`
  - Create PR (Homebrew team verifies code signing)
  - Once merged: users can `brew install clipstack` without tap

- [ ] Sparkle framework for auto-updates (optional, enhances user experience)
  - Add SPM dependency: sparkle-project/Sparkle
  - Generate public/private Ed25519 keys for signing updates
  - Implement update checking in app
  - Set up update feed on web server or GitHub Pages
  - Allows users to update with in-app notification instead of manual install

- [ ] Memory usage profiling for long-running sessions
  - Monitor memory growth over time with Instruments
  - Consider weak references if keeping large text items
  - Profile with Instruments (Allocations tool)
