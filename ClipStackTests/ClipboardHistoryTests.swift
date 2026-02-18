import XCTest
@testable import ClipStack

// Helper for tests to extract plain text value without touching production code
private extension ClipboardItem {
    var textValue: String? {
        guard case .plainText(let s) = content else { return nil }
        return s
    }
}

final class ClipboardHistoryTests: XCTestCase {

    var history: ClipboardHistory!

    override func setUp() {
        super.setUp()
        history = ClipboardHistory()
    }

    override func tearDown() {
        history = nil
        super.tearDown()
    }

    // MARK: - add()

    func testAddSingleItem() {
        history.add(.plainText("hello"))
        XCTAssertEqual(history.items.count, 1)
        XCTAssertEqual(history.items.first?.textValue, "hello")
    }

    func testAddInsertsAtFront() {
        history.add(.plainText("first"))
        history.add(.plainText("second"))
        XCTAssertEqual(history.items[0].textValue, "second")
        XCTAssertEqual(history.items[1].textValue, "first")
    }

    func testAddMultipleItemsOrderedMostRecentFirst() {
        history.add(.plainText("a"))
        history.add(.plainText("b"))
        history.add(.plainText("c"))
        XCTAssertEqual(history.items.map(\.textValue), ["c", "b", "a"])
    }

    // MARK: - add() ignores empty/whitespace (plainText only)

    func testAddEmptyStringIgnored() {
        history.add(.plainText(""))
        XCTAssertTrue(history.items.isEmpty)
    }

    func testAddWhitespaceOnlyIgnored() {
        history.add(.plainText("   "))
        XCTAssertTrue(history.items.isEmpty)
    }

    func testAddNewlineOnlyIgnored() {
        history.add(.plainText("\n\n"))
        XCTAssertTrue(history.items.isEmpty)
    }

    func testAddTabOnlyIgnored() {
        history.add(.plainText("\t\t"))
        XCTAssertTrue(history.items.isEmpty)
    }

    func testAddMixedWhitespaceIgnored() {
        history.add(.plainText(" \t\n "))
        XCTAssertTrue(history.items.isEmpty)
    }

    // MARK: - add() preserves original content

    func testAddPreservesOriginalTextWithWhitespace() {
        history.add(.plainText("  hello  "))
        XCTAssertEqual(history.items.first?.textValue, "  hello  ")
    }

    // MARK: - Duplicate handling (plainText)

    func testAddDuplicateMovesToTop() {
        history.add(.plainText("first"))
        history.add(.plainText("second"))
        history.add(.plainText("first"))
        XCTAssertEqual(history.items.count, 2)
        XCTAssertEqual(history.items[0].textValue, "first")
        XCTAssertEqual(history.items[1].textValue, "second")
    }

    func testAddDuplicateDoesNotIncreaseCount() {
        history.add(.plainText("x"))
        history.add(.plainText("y"))
        history.add(.plainText("x"))
        XCTAssertEqual(history.items.count, 2)
    }

    func testDuplicateDetectionUsesExactText() {
        history.add(.plainText("hello"))
        history.add(.plainText("hello "))
        XCTAssertEqual(history.items.count, 2)
    }

    func testDuplicateDetectionIsCaseSensitive() {
        history.add(.plainText("Hello"))
        history.add(.plainText("hello"))
        XCTAssertEqual(history.items.count, 2)
    }

    func testAddDuplicateUpdatesDate() {
        history.add(.plainText("text"))
        let firstDate = history.items.first!.copiedAt

        Thread.sleep(forTimeInterval: 0.01)

        history.add(.plainText("text"))
        let secondDate = history.items.first!.copiedAt
        XCTAssertGreaterThan(secondDate, firstDate)
    }

    // MARK: - Duplicate handling (multi-type)

    func testDedupImages() {
        let data = Data([1, 2, 3])
        history.add(.image(tiffData: data, thumbnail: NSImage()))
        history.add(.image(tiffData: data, thumbnail: NSImage()))
        XCTAssertEqual(history.items.count, 1)
    }

    func testDedupRichText() {
        let data = Data([4, 5, 6])
        history.add(.richText(rtfData: data, plainFallback: "hello"))
        history.add(.richText(rtfData: data, plainFallback: "hello"))
        XCTAssertEqual(history.items.count, 1)
    }

    func testDedupFileURLs() {
        let url = URL(fileURLWithPath: "/tmp/test.txt")
        history.add(.fileURL([url]))
        history.add(.fileURL([url]))
        XCTAssertEqual(history.items.count, 1)
    }

    func testDedupWebURL() {
        let url = URL(string: "https://example.com")!
        history.add(.webURL(url))
        history.add(.webURL(url))
        XCTAssertEqual(history.items.count, 1)
    }

    func testNoCrossDedupPlainTextVsWebURL() {
        history.add(.plainText("https://example.com"))
        history.add(.webURL(URL(string: "https://example.com")!))
        XCTAssertEqual(history.items.count, 2)
    }

    func testDifferentImageDataNotDeduped() {
        history.add(.image(tiffData: Data([1, 2, 3]), thumbnail: NSImage()))
        history.add(.image(tiffData: Data([4, 5, 6]), thumbnail: NSImage()))
        XCTAssertEqual(history.items.count, 2)
    }

    // MARK: - Max items cap

    func testMaxItemsCappedAtTen() {
        for i in 1...15 {
            history.add(.plainText("item \(i)"))
        }
        XCTAssertEqual(history.items.count, 10)
    }

    func testMaxItemsRemovesOldest() {
        for i in 1...11 {
            history.add(.plainText("item \(i)"))
        }
        XCTAssertEqual(history.items.count, 10)
        XCTAssertEqual(history.items.first?.textValue, "item 11")
        XCTAssertEqual(history.items.last?.textValue, "item 2")
        XCTAssertNil(history.items.first(where: { $0.textValue == "item 1" }))
    }

    func testExactlyTenItemsKeptAtCapacity() {
        for i in 1...10 {
            history.add(.plainText("item \(i)"))
        }
        XCTAssertEqual(history.items.count, 10)
        XCTAssertEqual(history.items.first?.textValue, "item 10")
        XCTAssertEqual(history.items.last?.textValue, "item 1")
    }

    // MARK: - item(at:)

    func testItemAtValidIndex() {
        history.add(.plainText("a"))
        history.add(.plainText("b"))
        history.add(.plainText("c"))
        XCTAssertEqual(history.item(at: 0)?.textValue, "c")
        XCTAssertEqual(history.item(at: 1)?.textValue, "b")
        XCTAssertEqual(history.item(at: 2)?.textValue, "a")
    }

    func testItemAtLastIndex() {
        for i in 1...10 {
            history.add(.plainText("item \(i)"))
        }
        XCTAssertEqual(history.item(at: 9)?.textValue, "item 1")
    }

    func testItemAtNegativeIndexReturnsNil() {
        history.add(.plainText("something"))
        XCTAssertNil(history.item(at: -1))
    }

    func testItemAtOutOfBoundsReturnsNil() {
        history.add(.plainText("only one"))
        XCTAssertNil(history.item(at: 1))
        XCTAssertNil(history.item(at: 100))
    }

    func testItemAtEmptyHistoryReturnsNil() {
        XCTAssertNil(history.item(at: 0))
    }

    // MARK: - clear()

    func testClearRemovesAllItems() {
        history.add(.plainText("a"))
        history.add(.plainText("b"))
        history.add(.plainText("c"))
        history.clear()
        XCTAssertTrue(history.items.isEmpty)
    }

    func testClearOnEmptyHistoryDoesNotCrash() {
        history.clear()
        XCTAssertTrue(history.items.isEmpty)
    }

    func testClearThenAddWorks() {
        history.add(.plainText("before"))
        history.clear()
        history.add(.plainText("after"))
        XCTAssertEqual(history.items.count, 1)
        XCTAssertEqual(history.items.first?.textValue, "after")
    }

    // MARK: - Singleton

    func testSharedInstanceExists() {
        XCTAssertNotNil(ClipboardHistory.shared)
    }

    func testSeparateInstancesAreIndependent() {
        let other = ClipboardHistory()
        history.add(.plainText("in history"))
        XCTAssertTrue(other.items.isEmpty)
    }

    // MARK: - Persistence

    private func tempStorageURL() -> URL {
        FileManager.default.temporaryDirectory
            .appendingPathComponent("ClipStackTest-\(UUID().uuidString).json")
    }

    func testItemsPersistedAndRestoredOnNewInstance() {
        let url = tempStorageURL()
        defer { try? FileManager.default.removeItem(at: url) }

        let h1 = ClipboardHistory(storageURL: url)
        h1.add(.plainText("persisted item"))
        h1.add(.webURL(URL(string: "https://example.com")!))

        let h2 = ClipboardHistory(storageURL: url)
        XCTAssertEqual(h2.items.count, 2)
        XCTAssertEqual(h2.items[0].textValue, nil) // webURL
        XCTAssertEqual(h2.items[1].textValue, "persisted item")
    }

    func testClearDeletesPersistedItems() {
        let url = tempStorageURL()
        defer { try? FileManager.default.removeItem(at: url) }

        let h1 = ClipboardHistory(storageURL: url)
        h1.add(.plainText("to be cleared"))

        let h2 = ClipboardHistory(storageURL: url)
        h2.clear()

        let h3 = ClipboardHistory(storageURL: url)
        XCTAssertTrue(h3.items.isEmpty)
    }

    func testImagesNotPersisted() {
        let url = tempStorageURL()
        defer { try? FileManager.default.removeItem(at: url) }

        let h1 = ClipboardHistory(storageURL: url)
        h1.add(.image(tiffData: Data([1, 2, 3]), thumbnail: NSImage()))
        h1.add(.plainText("text alongside image"))

        let h2 = ClipboardHistory(storageURL: url)
        // Image not persisted, only plain text survives
        XCTAssertEqual(h2.items.count, 1)
        XCTAssertEqual(h2.items[0].textValue, "text alongside image")
    }

    func testItemOrderPreservedAfterReload() {
        let url = tempStorageURL()
        defer { try? FileManager.default.removeItem(at: url) }

        let h1 = ClipboardHistory(storageURL: url)
        h1.add(.plainText("first"))
        h1.add(.plainText("second"))
        h1.add(.plainText("third"))

        let h2 = ClipboardHistory(storageURL: url)
        XCTAssertEqual(h2.items.map(\.textValue), ["third", "second", "first"])
    }

    func testMaxItemsEnforcedOnLoad() {
        let url = tempStorageURL()
        defer { try? FileManager.default.removeItem(at: url) }

        let h1 = ClipboardHistory(maxItems: 10, storageURL: url)
        for i in 1...8 { h1.add(.plainText("item \(i)")) }

        // Load with smaller cap
        let h2 = ClipboardHistory(maxItems: 3, storageURL: url)
        XCTAssertEqual(h2.items.count, 3)
        XCTAssertEqual(h2.items[0].textValue, "item 8")
    }

    func testMissingFileLoadsEmptyHistory() {
        let url = tempStorageURL() // file does not exist yet
        let h = ClipboardHistory(storageURL: url)
        XCTAssertTrue(h.items.isEmpty)
    }

    func testRichTextPersistedAndRestored() {
        let url = tempStorageURL()
        defer { try? FileManager.default.removeItem(at: url) }

        let rtfData = Data("fake-rtf".utf8)
        let h1 = ClipboardHistory(storageURL: url)
        h1.add(.richText(rtfData: rtfData, plainFallback: "rich text"))

        let h2 = ClipboardHistory(storageURL: url)
        guard case .richText(let data, let fallback) = h2.items.first?.content else {
            XCTFail("Expected richText")
            return
        }
        XCTAssertEqual(data, rtfData)
        XCTAssertEqual(fallback, "rich text")
    }
}
