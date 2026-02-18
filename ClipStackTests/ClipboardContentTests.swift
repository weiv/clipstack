import XCTest
@testable import ClipStack

final class ClipboardContentTests: XCTestCase {

    // MARK: - displayText

    func testDisplayTextPlainTextShort() {
        let content = ClipboardContent.plainText("hello")
        XCTAssertEqual(content.displayText, "hello")
    }

    func testDisplayTextPlainTextTruncatesAt80() {
        let long = String(repeating: "a", count: 81)
        let content = ClipboardContent.plainText(long)
        XCTAssertEqual(content.displayText, String(repeating: "a", count: 80) + "...")
    }

    func testDisplayTextPlainTextTrimsWhitespace() {
        let content = ClipboardContent.plainText("  hello  ")
        XCTAssertEqual(content.displayText, "hello")
    }

    func testDisplayTextWebURL() {
        let url = URL(string: "https://example.com/path")!
        let content = ClipboardContent.webURL(url)
        XCTAssertEqual(content.displayText, "https://example.com/path")
    }

    func testDisplayTextFileURLSingleFile() {
        let url = URL(fileURLWithPath: "/Users/test/document.pdf")
        let content = ClipboardContent.fileURL([url])
        XCTAssertEqual(content.displayText, "document.pdf")
    }

    func testDisplayTextFileURLMultipleFiles() {
        let urls = [
            URL(fileURLWithPath: "/tmp/a.txt"),
            URL(fileURLWithPath: "/tmp/b.txt"),
        ]
        let content = ClipboardContent.fileURL(urls)
        XCTAssertEqual(content.displayText, "a.txt, b.txt")
    }

    func testDisplayTextRichTextShort() {
        let data = Data()
        let content = ClipboardContent.richText(rtfData: data, plainFallback: "rich text")
        XCTAssertEqual(content.displayText, "rich text")
    }

    func testDisplayTextRichTextTruncatesAt80() {
        let long = String(repeating: "r", count: 90)
        let content = ClipboardContent.richText(rtfData: Data(), plainFallback: long)
        XCTAssertEqual(content.displayText, String(repeating: "r", count: 80) + "...")
    }

    func testDisplayTextRichTextTrimsWhitespace() {
        let content = ClipboardContent.richText(rtfData: Data(), plainFallback: "  trimmed  ")
        XCTAssertEqual(content.displayText, "trimmed")
    }

    func testDisplayTextImage() {
        let content = ClipboardContent.image(tiffData: Data(), thumbnail: NSImage())
        XCTAssertEqual(content.displayText, "Image")
    }

    // MARK: - typeIcon

    func testTypeIconPlainText() {
        XCTAssertEqual(ClipboardContent.plainText("").typeIcon, "doc.text")
    }

    func testTypeIconWebURL() {
        XCTAssertEqual(ClipboardContent.webURL(URL(string: "https://example.com")!).typeIcon, "link")
    }

    func testTypeIconFileURL() {
        XCTAssertEqual(ClipboardContent.fileURL([URL(fileURLWithPath: "/tmp")]).typeIcon, "doc")
    }

    func testTypeIconRichText() {
        XCTAssertEqual(ClipboardContent.richText(rtfData: Data(), plainFallback: "").typeIcon, "doc.richtext")
    }

    func testTypeIconImage() {
        XCTAssertEqual(ClipboardContent.image(tiffData: Data(), thumbnail: NSImage()).typeIcon, "photo")
    }

    // MARK: - Equatable

    func testPlainTextEqualSameString() {
        XCTAssertEqual(ClipboardContent.plainText("abc"), ClipboardContent.plainText("abc"))
    }

    func testPlainTextNotEqualDifferentString() {
        XCTAssertNotEqual(ClipboardContent.plainText("abc"), ClipboardContent.plainText("def"))
    }

    func testWebURLEqualSameURL() {
        let url = URL(string: "https://example.com")!
        XCTAssertEqual(ClipboardContent.webURL(url), ClipboardContent.webURL(url))
    }

    func testWebURLNotEqualDifferentURL() {
        XCTAssertNotEqual(
            ClipboardContent.webURL(URL(string: "https://a.com")!),
            ClipboardContent.webURL(URL(string: "https://b.com")!)
        )
    }

    func testFileURLEqualSameURLs() {
        let urls = [URL(fileURLWithPath: "/tmp/test.txt")]
        XCTAssertEqual(ClipboardContent.fileURL(urls), ClipboardContent.fileURL(urls))
    }

    func testRichTextEqualSameData() {
        let data = Data([1, 2, 3])
        XCTAssertEqual(
            ClipboardContent.richText(rtfData: data, plainFallback: "a"),
            ClipboardContent.richText(rtfData: data, plainFallback: "b")
        )
    }

    func testRichTextNotEqualDifferentData() {
        XCTAssertNotEqual(
            ClipboardContent.richText(rtfData: Data([1]), plainFallback: ""),
            ClipboardContent.richText(rtfData: Data([2]), plainFallback: "")
        )
    }

    func testImageEqualSameTiffData() {
        let data = Data([10, 20, 30])
        XCTAssertEqual(
            ClipboardContent.image(tiffData: data, thumbnail: NSImage()),
            ClipboardContent.image(tiffData: data, thumbnail: NSImage())
        )
    }

    func testImageNotEqualDifferentTiffData() {
        XCTAssertNotEqual(
            ClipboardContent.image(tiffData: Data([1]), thumbnail: NSImage()),
            ClipboardContent.image(tiffData: Data([2]), thumbnail: NSImage())
        )
    }

    func testDifferentCasesNotEqual() {
        XCTAssertNotEqual(
            ClipboardContent.plainText("https://example.com"),
            ClipboardContent.webURL(URL(string: "https://example.com")!)
        )
        XCTAssertNotEqual(
            ClipboardContent.plainText("hello"),
            ClipboardContent.richText(rtfData: Data(), plainFallback: "hello")
        )
    }
}
