# MacClip

A lightweight macOS menu bar clipboard manager. Keeps your last 10 copied text items and lets you paste them with a click or keyboard shortcut.
This is an experiment in LLM assisted coding - I was missing the extended clipboard from ChromeOS, and this problem seemed like a good example to try to develop using Claude Code, Gemini CLI, Amp and such. Feel free to add features.

## Features

- Lives in the menu bar — no Dock icon, no windows
- Automatically captures text copied to the clipboard
- Stores the 10 most recent items (duplicates move to top)
- Paste any item by clicking it in the menu
- Global keyboard shortcuts: **⌘⌥1** through **⌘⌥0** to paste items 1–10
- Launch at Login toggle
- Clear History option

## Requirements

- macOS 13.0+
- Accessibility permission (prompted on first launch, needed for paste simulation)

## Build & Run

```bash
# Build
xcodebuild -project MacClip.xcodeproj -scheme MacClip -configuration Debug build

# Run
open "$(xcodebuild -project MacClip.xcodeproj -scheme MacClip -showBuildSettings 2>/dev/null | grep ' BUILT_PRODUCTS_DIR' | awk '{print $3}')/MacClip.app"
```

## Testing

```bash
xcodebuild test -project MacClip.xcodeproj -scheme MacClip -destination 'platform=macOS'
```

44 unit tests cover the model layer:

- **ClipboardItemTests** (17 tests) — display text truncation, whitespace trimming, equality, identity
- **ClipboardHistoryTests** (27 tests) — add/dedup/cap behavior, index access, clear, edge cases

## Architecture

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
│   └── PermissionService.swift# AXIsProcessTrustedWithOptions check/prompt
└── Views/
    └── ClipboardMenuView.swift# Menu items, Clear History, Launch at Login, Quit

MacClipTests/
├── ClipboardItemTests.swift
└── ClipboardHistoryTests.swift
```

## How It Works

MacClip polls the system clipboard every 0.5 seconds. When you click an item or use a shortcut, it writes the text to the clipboard and simulates **⌘V** via `CGEvent` to paste into the active app.
