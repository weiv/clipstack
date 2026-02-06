# MacClip

A lightweight macOS menu bar clipboard manager. Keeps your last 10 copied text items and lets you paste them with a click or keyboard shortcut.

## Features

- Lives in the menu bar — no Dock icon, no windows
- Automatically captures text copied to the clipboard
- Stores the 10 most recent items (duplicates move to top)
- Paste any item by clicking it in the menu
- Global keyboard shortcuts: **⌘⇧1** through **⌘⇧0** to paste items 1–10
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

## How It Works

MacClip polls the system clipboard every 0.5 seconds. When you click an item or use a shortcut, it writes the text to the clipboard and simulates **⌘V** via `CGEvent` to paste into the active app.
