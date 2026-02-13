# ClipStack Development Scripts

Quick commands to speed up development. Add the scripts directory to your PATH for global access:

```bash
export PATH="$PATH:/Users/weivsara/Library/Mobile Documents/com~apple~CloudDocs/src/mac-clip/scripts"
```

Then use any script from the project root or anywhere.

---

## build-run

Build and launch the ClipStack app in one command.

```bash
./scripts/build-run
# or (if in PATH):
build-run
```

**What it does:**
- Builds the project with `xcodebuild` in Debug configuration
- Extracts the build output path
- Launches the app

Useful during development to quickly test changes.

---

## test

Run the test suite.

```bash
./scripts/test
# or (if in PATH):
test
```

**What it does:**
- Runs all tests with `xcodebuild test`
- Uses macOS platform destination
- Exits with error if any tests fail

---

## add-service

Generate a new service with boilerplate following project patterns.

```bash
./scripts/add-service MyService
# or (if in PATH):
add-service MyService
```

**What it does:**
- Creates `ClipStack/Services/MyService.swift`
- Generates proper class structure with `init(history:)`, `start()`, `stop()`
- Prompts to create corresponding test file
- Reminds you to integrate with AppDelegate

**Example:**
```bash
add-service NotificationService
```

Creates a service template ready for implementation, with optional tests.

---

## add-test

Generate a test file for a model or service.

```bash
./scripts/add-test MyModel
# or (if in PATH):
add-test MyModel
```

**What it does:**
- Creates `ClipStackTests/MyModelTests.swift`
- Auto-detects if it's a service or model
- Generates appropriate test template with setUp/tearDown
- Uses `@testable import ClipStack` following project pattern

**Example:**
```bash
add-test ClipboardCache
```

Creates a test file with basic test cases ready for implementation.
