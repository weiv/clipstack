import XCTest
@testable import ClipStack

final class ClipboardItemTests: XCTestCase {

    // MARK: - displayText (plainText)

    func testDisplayTextShortText() {
        let item = ClipboardItem(content: .plainText("Hello, world!"), copiedAt: Date())
        XCTAssertEqual(item.displayText, "Hello, world!")
    }

    func testDisplayTextExactly80Characters() {
        let text = String(repeating: "a", count: 80)
        let item = ClipboardItem(content: .plainText(text), copiedAt: Date())
        XCTAssertEqual(item.displayText, text)
        XCTAssertEqual(item.displayText.count, 80)
    }

    func testDisplayTextTruncatesAt81Characters() {
        let text = String(repeating: "b", count: 81)
        let item = ClipboardItem(content: .plainText(text), copiedAt: Date())
        XCTAssertEqual(item.displayText, String(repeating: "b", count: 80) + "...")
        XCTAssertEqual(item.displayText.count, 83)
    }

    func testDisplayTextTruncatesLongText() {
        let text = String(repeating: "x", count: 200)
        let item = ClipboardItem(content: .plainText(text), copiedAt: Date())
        XCTAssertTrue(item.displayText.hasSuffix("..."))
        XCTAssertEqual(item.displayText.count, 83)
    }

    func testDisplayTextTrimsLeadingAndTrailingWhitespace() {
        let item = ClipboardItem(content: .plainText("  hello  "), copiedAt: Date())
        XCTAssertEqual(item.displayText, "hello")
    }

    func testDisplayTextTrimsNewlines() {
        let item = ClipboardItem(content: .plainText("\nhello\n"), copiedAt: Date())
        XCTAssertEqual(item.displayText, "hello")
    }

    func testDisplayTextTrimsTabsAndMixed() {
        let item = ClipboardItem(content: .plainText("\t \n  some text  \n\t"), copiedAt: Date())
        XCTAssertEqual(item.displayText, "some text")
    }

    func testDisplayTextWhitespaceOnlyReturnsEmpty() {
        let item = ClipboardItem(content: .plainText("   \n\t  "), copiedAt: Date())
        XCTAssertEqual(item.displayText, "")
    }

    func testDisplayTextPreservesInternalWhitespace() {
        let item = ClipboardItem(content: .plainText("hello   world"), copiedAt: Date())
        XCTAssertEqual(item.displayText, "hello   world")
    }

    func testDisplayTextTruncationAppliesAfterTrimming() {
        let inner = String(repeating: "c", count: 90)
        let item = ClipboardItem(content: .plainText("  \(inner)  "), copiedAt: Date())
        XCTAssertEqual(item.displayText, String(repeating: "c", count: 80) + "...")
    }

    func testDisplayTextImage() {
        let item = ClipboardItem(content: .image(tiffData: Data(), thumbnail: NSImage()), copiedAt: Date())
        XCTAssertEqual(item.displayText, "Image")
    }

    func testDisplayTextWebURL() {
        let url = URL(string: "https://example.com")!
        let item = ClipboardItem(content: .webURL(url), copiedAt: Date())
        XCTAssertEqual(item.displayText, "https://example.com")
    }

    func testDisplayTextFileURL() {
        let url = URL(fileURLWithPath: "/tmp/test.txt")
        let item = ClipboardItem(content: .fileURL([url]), copiedAt: Date())
        XCTAssertEqual(item.displayText, "test.txt")
    }

    // MARK: - Equatable

    func testEqualitySameContent() {
        let a = ClipboardItem(content: .plainText("same"), copiedAt: Date())
        let b = ClipboardItem(content: .plainText("same"), copiedAt: Date())
        XCTAssertEqual(a, b)
    }

    func testEqualityDifferentContent() {
        let a = ClipboardItem(content: .plainText("alpha"), copiedAt: Date())
        let b = ClipboardItem(content: .plainText("beta"), copiedAt: Date())
        XCTAssertNotEqual(a, b)
    }

    func testEqualityIgnoresDate() {
        let early = Date(timeIntervalSince1970: 0)
        let late = Date(timeIntervalSince1970: 1_000_000)
        let a = ClipboardItem(content: .plainText("same"), copiedAt: early)
        let b = ClipboardItem(content: .plainText("same"), copiedAt: late)
        XCTAssertEqual(a, b)
    }

    func testEqualityIsCaseSensitive() {
        let a = ClipboardItem(content: .plainText("Hello"), copiedAt: Date())
        let b = ClipboardItem(content: .plainText("hello"), copiedAt: Date())
        XCTAssertNotEqual(a, b)
    }

    func testEqualityDifferentContentTypes() {
        let a = ClipboardItem(content: .plainText("https://example.com"), copiedAt: Date())
        let b = ClipboardItem(content: .webURL(URL(string: "https://example.com")!), copiedAt: Date())
        XCTAssertNotEqual(a, b)
    }

    // MARK: - Identity

    func testUniqueIds() {
        let a = ClipboardItem(content: .plainText("same"), copiedAt: Date())
        let b = ClipboardItem(content: .plainText("same"), copiedAt: Date())
        XCTAssertNotEqual(a.id, b.id)
    }

    // MARK: - Stored content

    func testContentPreservesOriginalText() {
        let original = "  hello  "
        let item = ClipboardItem(content: .plainText(original), copiedAt: Date())
        if case .plainText(let s) = item.content {
            XCTAssertEqual(s, original)
        } else {
            XCTFail("Expected plainText content")
        }
    }

    func testCopiedAtStoresDate() {
        let date = Date(timeIntervalSince1970: 12345)
        let item = ClipboardItem(content: .plainText("test"), copiedAt: date)
        XCTAssertEqual(item.copiedAt, date)
    }
}
