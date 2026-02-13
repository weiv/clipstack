import XCTest
@testable import ClipStack

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
        history.add("hello")
        XCTAssertEqual(history.items.count, 1)
        XCTAssertEqual(history.items.first?.text, "hello")
    }

    func testAddInsertsAtFront() {
        history.add("first")
        history.add("second")
        XCTAssertEqual(history.items[0].text, "second")
        XCTAssertEqual(history.items[1].text, "first")
    }

    func testAddMultipleItemsOrderedMostRecentFirst() {
        history.add("a")
        history.add("b")
        history.add("c")
        XCTAssertEqual(history.items.map(\.text), ["c", "b", "a"])
    }

    // MARK: - add() ignores empty/whitespace

    func testAddEmptyStringIgnored() {
        history.add("")
        XCTAssertTrue(history.items.isEmpty)
    }

    func testAddWhitespaceOnlyIgnored() {
        history.add("   ")
        XCTAssertTrue(history.items.isEmpty)
    }

    func testAddNewlineOnlyIgnored() {
        history.add("\n\n")
        XCTAssertTrue(history.items.isEmpty)
    }

    func testAddTabOnlyIgnored() {
        history.add("\t\t")
        XCTAssertTrue(history.items.isEmpty)
    }

    func testAddMixedWhitespaceIgnored() {
        history.add(" \t\n ")
        XCTAssertTrue(history.items.isEmpty)
    }

    // MARK: - add() preserves original text

    func testAddPreservesOriginalTextWithWhitespace() {
        history.add("  hello  ")
        XCTAssertEqual(history.items.first?.text, "  hello  ")
    }

    // MARK: - Duplicate handling

    func testAddDuplicateMovesToTop() {
        history.add("first")
        history.add("second")
        history.add("first")
        XCTAssertEqual(history.items.count, 2)
        XCTAssertEqual(history.items[0].text, "first")
        XCTAssertEqual(history.items[1].text, "second")
    }

    func testAddDuplicateDoesNotIncreaseCount() {
        history.add("x")
        history.add("y")
        history.add("x")
        XCTAssertEqual(history.items.count, 2)
    }

    func testDuplicateDetectionUsesExactText() {
        // "hello" and "hello " are different
        history.add("hello")
        history.add("hello ")
        XCTAssertEqual(history.items.count, 2)
    }

    func testDuplicateDetectionIsCaseSensitive() {
        history.add("Hello")
        history.add("hello")
        XCTAssertEqual(history.items.count, 2)
    }

    func testAddDuplicateUpdatesDate() {
        history.add("text")
        let firstDate = history.items.first!.copiedAt

        // Small sleep to ensure different timestamp
        Thread.sleep(forTimeInterval: 0.01)

        history.add("text")
        let secondDate = history.items.first!.copiedAt
        XCTAssertGreaterThan(secondDate, firstDate)
    }

    // MARK: - Max items cap

    func testMaxItemsCappedAtTen() {
        for i in 1...15 {
            history.add("item \(i)")
        }
        XCTAssertEqual(history.items.count, 10)
    }

    func testMaxItemsRemovesOldest() {
        for i in 1...11 {
            history.add("item \(i)")
        }
        XCTAssertEqual(history.items.count, 10)
        // Most recent is first
        XCTAssertEqual(history.items.first?.text, "item 11")
        // Oldest surviving is "item 2" (item 1 was pushed out)
        XCTAssertEqual(history.items.last?.text, "item 2")
        // "item 1" should be gone
        XCTAssertNil(history.items.first(where: { $0.text == "item 1" }))
    }

    func testExactlyTenItemsKeptAtCapacity() {
        for i in 1...10 {
            history.add("item \(i)")
        }
        XCTAssertEqual(history.items.count, 10)
        XCTAssertEqual(history.items.first?.text, "item 10")
        XCTAssertEqual(history.items.last?.text, "item 1")
    }

    // MARK: - item(at:)

    func testItemAtValidIndex() {
        history.add("a")
        history.add("b")
        history.add("c")
        XCTAssertEqual(history.item(at: 0)?.text, "c")
        XCTAssertEqual(history.item(at: 1)?.text, "b")
        XCTAssertEqual(history.item(at: 2)?.text, "a")
    }

    func testItemAtLastIndex() {
        for i in 1...10 {
            history.add("item \(i)")
        }
        XCTAssertEqual(history.item(at: 9)?.text, "item 1")
    }

    func testItemAtNegativeIndexReturnsNil() {
        history.add("something")
        XCTAssertNil(history.item(at: -1))
    }

    func testItemAtOutOfBoundsReturnsNil() {
        history.add("only one")
        XCTAssertNil(history.item(at: 1))
        XCTAssertNil(history.item(at: 100))
    }

    func testItemAtEmptyHistoryReturnsNil() {
        XCTAssertNil(history.item(at: 0))
    }

    // MARK: - clear()

    func testClearRemovesAllItems() {
        history.add("a")
        history.add("b")
        history.add("c")
        history.clear()
        XCTAssertTrue(history.items.isEmpty)
    }

    func testClearOnEmptyHistoryDoesNotCrash() {
        history.clear()
        XCTAssertTrue(history.items.isEmpty)
    }

    func testClearThenAddWorks() {
        history.add("before")
        history.clear()
        history.add("after")
        XCTAssertEqual(history.items.count, 1)
        XCTAssertEqual(history.items.first?.text, "after")
    }

    // MARK: - Singleton

    func testSharedInstanceExists() {
        XCTAssertNotNil(ClipboardHistory.shared)
    }

    func testSeparateInstancesAreIndependent() {
        let other = ClipboardHistory()
        history.add("in history")
        XCTAssertTrue(other.items.isEmpty)
    }
}
