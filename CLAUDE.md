# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

mac-clip is a native macOS clipboard management app. It lives in the menu bar, monitors the system clipboard, maintains the last 10 copied text items in memory, and lets users paste previous items via click or keyboard shortcuts (Command+Option+1 through Command+Option+0).

## Architecture

- **SwiftUI + MenuBarExtra** (macOS 13+), `.menu` style for native dropdown
- **Non-sandboxed** — required for `CGEventPost` (paste simulation)
- **Timer-based clipboard polling** — checks `NSPasteboard.general.changeCount` every 0.5s
  - Idempotent `start()` method prevents multiple timers if called repeatedly
  - Precise `skipNextChangeCount` tracking eliminates race conditions on paste operations
- **HotKey library** ([soffes/HotKey](https://github.com/soffes/HotKey)) for global shortcut registration
- **`ClipboardHistory` singleton** (`ObservableObject`) shared across the app

### Key Files

```
MacClip/
├── MacClipApp.swift           # @main, MenuBarExtra scene, AppDelegate adaptor
├── AppDelegate.swift          # Init services, permission check
├── Models/
│   ├── ClipboardItem.swift    # Identifiable struct (id, text, copiedAt, displayText)
│   └── ClipboardHistory.swift # ObservableObject singleton, @Published items
├── Services/
│   ├── ClipboardMonitor.swift # Timer polling, changeCount tracking
│   ├── PasteService.swift     # Pasteboard write + CGEvent Cmd+V simulation
│   ├── HotKeyManager.swift    # 10 HotKey instances for Command+Option+1-0
│   ├── PermissionService.swift# AXIsProcessTrustedWithOptions check/prompt
│   └── PreferencesManager.swift# @AppStorage for Launch at Login, extensible for future prefs
├── Views/
│   ├── ClipboardMenuView.swift# Menu items, Clear History, Preferences, Quit
│   └── PreferencesView.swift  # Settings Form (Launch at Login toggle)
└── Helpers/
    └── SettingsOpener.swift   # Window controller for preferences panel

MacClipTests/
├── ClipboardItemTests.swift     # displayText, Equatable, identity
├── ClipboardHistoryTests.swift  # add, dedup, cap, item(at:), clear
└── ClipboardMonitorTests.swift  # start() idempotency, timer management
```

## Build Commands

```bash
# Build
xcodebuild -project MacClip.xcodeproj -scheme MacClip -configuration Debug build

# Run
open "$(xcodebuild -project MacClip.xcodeproj -scheme MacClip -showBuildSettings 2>/dev/null | grep ' BUILT_PRODUCTS_DIR' | awk '{print $3}')/MacClip.app"

# Test
xcodebuild test -project MacClip.xcodeproj -scheme MacClip -destination 'platform=macOS'
```

## Testing

- Tests use `@testable import MacClip` with a hosted test bundle (TEST_HOST = MacClip.app)
- `ClipboardHistory.init()` is internal (not private) so tests can create isolated instances
- Always add tests when modifying model or service code

## Clipboard Monitoring & Paste Logic

### How Paste Operations Work

1. **User Action**: User selects an item from menu or uses Command+Option+1-0 shortcut
2. **PasteService.paste(text)**:
   - Records the current pasteboard `changeCount`
   - Sets `skipNextChangeCount = changeCount + 1` to mark the expected state change
   - Writes text to pasteboard via `NSPasteboard.setString()`
   - Waits 50ms (allows menu to close and previous app to regain focus)
   - Simulates Cmd+V via CGEvent
3. **ClipboardMonitor Detection**:
   - Polling timer (every 0.5s) detects the changeCount increment
   - Checks if the change matches `skipNextChangeCount`
   - If match: skips adding to history, clears `skipNextChangeCount`, returns
   - If no match: adds the change to `ClipboardHistory`

### Why This Design

- **No 600ms timeout**: Previous approach used a time-based flag that could drop real user clipboard entries if they copied within 600ms of a paste
- **Precise tracking**: Uses the actual pasteboard changeCount to identify our own operations
- **Race-condition free**: Works atomically without timing windows

## Permissions

### Accessibility Permission

- Required for CGEvent-based paste simulation (Cmd+V key press)
- Checked once at app launch via `PermissionService.checkAccessibility()`
- Avoids repeated permission dialogs by tracking whether we've already prompted
- If denied, logs clear instructions on how to grant permission in System Settings

## Preferences Architecture

The preferences system uses a singleton pattern similar to `ClipboardHistory`:

- **PreferencesManager** (Services/) — `ObservableObject` singleton with `@AppStorage` for persistence
  - `launchAtLogin: Bool` — persists to UserDefaults, syncs with ServiceManagement
  - Reconciles state on failure: if register/unregister fails, syncs back to actual system state to prevent UI desynchronization
  - Extensible for future preferences (history size, polling interval, etc.)
  - Syncs with system state on init to handle out-of-app preference changes

- **PreferencesView** (Views/) — SwiftUI Form for the preferences window UI
  - Binds to `PreferencesManager.shared` for reactive state
  - Organized in sections for logical grouping

- **SettingsOpener** (Helpers/) — Window management for the preferences panel
  - Creates NSWindow with PreferencesView hosted in NSHostingController
  - Manages activation policy changes (`.accessory` ↔ `.regular`) for menu bar app behavior
  - Called from ClipboardMenuView "Preferences..." button

- **AppDelegate** — Handles Dock icon visibility
  - `applicationShouldTerminateAfterLastWindowClosed(_:)` hides app from Dock when preferences window closes
  - Uses `NSApp.setActivationPolicy(.accessory)` + `NSApp.deactivate()` to restore menu-bar-only mode

## Requirements

- macOS 13.0+
- Xcode 15+
- Accessibility permission (for paste simulation via CGEvent)
