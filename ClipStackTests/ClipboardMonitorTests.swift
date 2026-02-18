import XCTest
@testable import ClipStack

final class ClipboardMonitorTests: XCTestCase {

    var monitor: ClipboardMonitor!
    var history: ClipboardHistory!

    override func setUp() {
        super.setUp()
        history = ClipboardHistory()
        monitor = ClipboardMonitor(history: history)
    }

    override func tearDown() {
        monitor.stop()
        monitor = nil
        history = nil
        super.tearDown()
    }

    // MARK: - start() idempotency

    func testStartIsIdempotent() {
        monitor.start()
        monitor.start()
        monitor.start()

        let expectation = XCTestExpectation(description: "Timer runs after multiple starts")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)

        monitor.stop()
        monitor.stop()
    }

    func testStartStopStartCycle() {
        monitor.start()

        let expectation1 = XCTestExpectation(description: "First cycle")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            expectation1.fulfill()
        }
        wait(for: [expectation1], timeout: 1.0)

        monitor.stop()
        monitor.start()

        let expectation2 = XCTestExpectation(description: "Second cycle")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            expectation2.fulfill()
        }
        wait(for: [expectation2], timeout: 1.0)

        monitor.stop()
    }

    // MARK: - readContent

    private func makePasteboard() -> NSPasteboard {
        let pb = NSPasteboard(name: NSPasteboard.Name("test.\(UUID().uuidString)"))
        pb.clearContents()
        return pb
    }

    func testReadContentPlainText() {
        let pb = makePasteboard()
        pb.setString("hello world", forType: .string)

        let content = ClipboardMonitor.readContent(from: pb)
        guard case .plainText(let s) = content else {
            XCTFail("Expected plainText, got \(String(describing: content))")
            return
        }
        XCTAssertEqual(s, "hello world")
    }

    func testReadContentWebURL() {
        let pb = makePasteboard()
        pb.setString("https://example.com/path", forType: .string)

        let content = ClipboardMonitor.readContent(from: pb)
        guard case .webURL(let url) = content else {
            XCTFail("Expected webURL, got \(String(describing: content))")
            return
        }
        XCTAssertEqual(url.absoluteString, "https://example.com/path")
    }

    func testReadContentHTTPAlsoClassifiedAsWebURL() {
        let pb = makePasteboard()
        pb.setString("http://example.com", forType: .string)

        let content = ClipboardMonitor.readContent(from: pb)
        guard case .webURL(let url) = content else {
            XCTFail("Expected webURL, got \(String(describing: content))")
            return
        }
        XCTAssertEqual(url.scheme, "http")
    }

    func testReadContentURLWithoutHostIsPlainText() {
        let pb = makePasteboard()
        pb.setString("https://", forType: .string)

        let content = ClipboardMonitor.readContent(from: pb)
        guard case .plainText = content else {
            XCTFail("Expected plainText for URL without host, got \(String(describing: content))")
            return
        }
    }

    func testReadContentFTPIsPlainText() {
        let pb = makePasteboard()
        pb.setString("ftp://example.com", forType: .string)

        let content = ClipboardMonitor.readContent(from: pb)
        guard case .plainText = content else {
            XCTFail("Expected plainText for ftp:// URL, got \(String(describing: content))")
            return
        }
    }

    func testReadContentEmptyPasteboardReturnsNil() {
        let pb = makePasteboard()
        let content = ClipboardMonitor.readContent(from: pb)
        XCTAssertNil(content)
    }

    func testReadContentFileURL() {
        let pb = makePasteboard()
        let fileURL = URL(fileURLWithPath: "/tmp")
        pb.writeObjects([fileURL as NSURL])

        let content = ClipboardMonitor.readContent(from: pb)
        guard case .fileURL(let urls) = content else {
            XCTFail("Expected fileURL, got \(String(describing: content))")
            return
        }
        XCTAssertFalse(urls.isEmpty)
    }
}
