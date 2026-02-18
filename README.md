# ClipStack

A lightweight macOS menu bar clipboard manager. Keeps your recent copied items and lets you paste them with a click or keyboard shortcut.

This is an experiment in LLM-assisted coding — I was missing the extended clipboard from ChromeOS and this problem seemed like a good fit to build with Claude Code. Feel free to add features.

## Features

- Lives in the menu bar — no Dock icon, no windows
- Captures text, URLs, images, files, and rich text
- Stores up to 50 recent items (configurable), duplicates move to top
- Paste any item by clicking or via keyboard shortcut (⌘⌥1–0 by default)
- Customizable modifier keys (⌘⌥, ⌘⇧, ⌃⌥, ⌃⇧, ⌘⌃)
- Timestamps and full-content tooltips on each item
- Paste confirmation HUD
- Configurable history size and polling interval
- Launch at Login toggle
- Auto-updates via Sparkle

## Requirements

- macOS 13.0+
- Accessibility permission (prompted on first launch, needed for paste simulation)

## Installation

### DMG (Recommended)

Download the latest `ClipStack.dmg` from the [Releases page](https://github.com/weiv/clipstack/releases/latest), open it, and drag ClipStack to Applications.

ClipStack will notify you of updates automatically via Sparkle — no need to reinstall manually.

### Homebrew

```bash
brew tap weiv/clipstack
brew install clipstack
```

> Note: Homebrew installs don't receive Sparkle auto-updates. Run `brew upgrade clipstack` to update manually.

### From Source

```bash
git clone https://github.com/weiv/clipstack.git
cd clipstack
xcodebuild -project ClipStack.xcodeproj -scheme ClipStack -configuration Release build
open "$(xcodebuild -project ClipStack.xcodeproj -scheme ClipStack -showBuildSettings 2>/dev/null | grep ' BUILT_PRODUCTS_DIR' | awk '{print $3}')/ClipStack.app"
```

## Build & Run (Development)

```bash
# Build
xcodebuild -project ClipStack.xcodeproj -scheme ClipStack -configuration Debug build

# Run
open "$(xcodebuild -project ClipStack.xcodeproj -scheme ClipStack -showBuildSettings 2>/dev/null | grep ' BUILT_PRODUCTS_DIR' | awk '{print $3}')/ClipStack.app"

# Test
xcodebuild test -project ClipStack.xcodeproj -scheme ClipStack -destination 'platform=macOS'
```

## Architecture

```
ClipStack/
├── ClipStackApp.swift             # @main, MenuBarExtra scene, AppDelegate adaptor
├── AppDelegate.swift              # Init services, Sparkle updater controller
├── Models/
│   ├── ClipboardContent.swift     # Enum: plainText, webURL, fileURL, richText, image
│   ├── ClipboardItem.swift        # Identifiable + Codable struct
│   └── ClipboardHistory.swift     # ObservableObject singleton, disk persistence
├── Services/
│   ├── ClipboardMonitor.swift     # Timer polling, changeCount tracking
│   ├── PasteService.swift         # Pasteboard write + CGEvent Cmd+V simulation
│   ├── HotKeyManager.swift        # 10 HotKey instances, dynamic modifier support
│   ├── PermissionService.swift    # Accessibility permission check/prompt
│   └── PreferencesManager.swift   # @AppStorage, hotkey modifiers, launch at login
├── Views/
│   ├── ClipboardMenuView.swift    # Menu items with icons, timestamps, tooltips
│   ├── PreferencesView.swift      # Settings form
│   └── AboutView.swift            # Version, author, weivco.com
└── Helpers/
    ├── SettingsOpener.swift        # Window controller for preferences + about
    └── PasteHUD.swift             # Floating "Pasted ✓" confirmation panel
```

## How It Works

ClipStack polls the system clipboard every 0.5 seconds (configurable). When you click an item or use a shortcut, it writes the original pasteboard data back (preserving formatting, file references, and images) and simulates **⌘V** via `CGEvent` to paste into the active app.
