# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

mac-clip is a native macOS clipboard management app. It lives in the menu bar, monitors the system clipboard, maintains the last 10 copied text items in memory, and lets users paste previous items via click or keyboard shortcuts (Cmd+Shift+1 through Cmd+Shift+0).

## Architecture

- **SwiftUI + MenuBarExtra** (macOS 13+), `.menu` style for native dropdown
- **Non-sandboxed** — required for `CGEventPost` (paste simulation)
- **Timer-based clipboard polling** — checks `NSPasteboard.general.changeCount` every 0.5s
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
│   ├── HotKeyManager.swift    # 10 HotKey instances for Cmd+Shift+1-0
│   ├── PermissionService.swift# AXIsProcessTrustedWithOptions check/prompt
│   └── PreferencesManager.swift# @AppStorage for Launch at Login, extensible for future prefs
├── Views/
│   ├── ClipboardMenuView.swift# Menu items, Clear History, Preferences, Quit
│   └── PreferencesView.swift  # Settings Form (Launch at Login toggle)
└── Helpers/
    └── SettingsOpener.swift   # Window controller for preferences panel

MacClipTests/
├── ClipboardItemTests.swift   # displayText, Equatable, identity
└── ClipboardHistoryTests.swift# add, dedup, cap, item(at:), clear
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

## Preferences Architecture

The preferences system uses a singleton pattern similar to `ClipboardHistory`:

- **PreferencesManager** (Services/) — `ObservableObject` singleton with `@AppStorage` for persistence
  - `launchAtLogin: Bool` — persists to UserDefaults, syncs with ServiceManagement
  - Extensible for future preferences (history size, polling interval, etc.)
  - Thread-safe initialization and property updates

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
