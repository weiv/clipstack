import XCTest
@testable import ClipStack

final class ClipboardItemTests: XCTestCase {

    // MARK: - displayText

    func testDisplayTextShortText() {
        let item = ClipboardItem(text: "Hello, world!", copiedAt: Date())
        XCTAssertEqual(item.displayText, "Hello, world!")
    }

    func testDisplayTextExactly80Characters() {
        let text = String(repeating: "a", count: 80)
        let item = ClipboardItem(text: text, copiedAt: Date())
        XCTAssertEqual(item.displayText, text)
        XCTAssertEqual(item.displayText.count, 80)
    }

    func testDisplayTextTruncatesAt81Characters() {
        let text = String(repeating: "b", count: 81)
        let item = ClipboardItem(text: text, copiedAt: Date())
        XCTAssertEqual(item.displayText, String(repeating: "b", count: 80) + "...")
        XCTAssertEqual(item.displayText.count, 83) // 80 + "..."
    }

    func testDisplayTextTruncatesLongText() {
        let text = String(repeating: "x", count: 200)
        let item = ClipboardItem(text: text, copiedAt: Date())
        XCTAssertTrue(item.displayText.hasSuffix("..."))
        XCTAssertEqual(item.displayText.count, 83)
    }

    func testDisplayTextTrimsLeadingAndTrailingWhitespace() {
        let item = ClipboardItem(text: "  hello  ", copiedAt: Date())
        XCTAssertEqual(item.displayText, "hello")
    }

    func testDisplayTextTrimsNewlines() {
        let item = ClipboardItem(text: "\nhello\n", copiedAt: Date())
        XCTAssertEqual(item.displayText, "hello")
    }

    func testDisplayTextTrimsTabsAndMixed() {
        let item = ClipboardItem(text: "\t \n  some text  \n\t", copiedAt: Date())
        XCTAssertEqual(item.displayText, "some text")
    }

    func testDisplayTextWhitespaceOnlyReturnsEmpty() {
        let item = ClipboardItem(text: "   \n\t  ", copiedAt: Date())
        XCTAssertEqual(item.displayText, "")
    }

    func testDisplayTextPreservesInternalWhitespace() {
        let item = ClipboardItem(text: "hello   world", copiedAt: Date())
        XCTAssertEqual(item.displayText, "hello   world")
    }

    func testDisplayTextTruncationAppliesAfterTrimming() {
        // 90 chars of content with leading/trailing spaces
        let inner = String(repeating: "c", count: 90)
        let item = ClipboardItem(text: "  \(inner)  ", copiedAt: Date())
        XCTAssertEqual(item.displayText, String(repeating: "c", count: 80) + "...")
    }

    // MARK: - Equatable

    func testEqualitySameText() {
        let a = ClipboardItem(text: "same", copiedAt: Date())
        let b = ClipboardItem(text: "same", copiedAt: Date())
        XCTAssertEqual(a, b)
    }

    func testEqualityDifferentText() {
        let a = ClipboardItem(text: "alpha", copiedAt: Date())
        let b = ClipboardItem(text: "beta", copiedAt: Date())
        XCTAssertNotEqual(a, b)
    }

    func testEqualityIgnoresDate() {
        let early = Date(timeIntervalSince1970: 0)
        let late = Date(timeIntervalSince1970: 1_000_000)
        let a = ClipboardItem(text: "same", copiedAt: early)
        let b = ClipboardItem(text: "same", copiedAt: late)
        XCTAssertEqual(a, b)
    }

    func testEqualityIsCaseSensitive() {
        let a = ClipboardItem(text: "Hello", copiedAt: Date())
        let b = ClipboardItem(text: "hello", copiedAt: Date())
        XCTAssertNotEqual(a, b)
    }

    // MARK: - Identity

    func testUniqueIds() {
        let a = ClipboardItem(text: "same", copiedAt: Date())
        let b = ClipboardItem(text: "same", copiedAt: Date())
        XCTAssertNotEqual(a.id, b.id)
    }

    // MARK: - Stored text

    func testTextPreservesOriginalContent() {
        let original = "  hello  "
        let item = ClipboardItem(text: original, copiedAt: Date())
        XCTAssertEqual(item.text, original)
    }

    func testCopiedAtStoresDate() {
        let date = Date(timeIntervalSince1970: 12345)
        let item = ClipboardItem(text: "test", copiedAt: date)
        XCTAssertEqual(item.copiedAt, date)
    }
}
