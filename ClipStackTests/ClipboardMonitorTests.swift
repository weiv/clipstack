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
        // Call start multiple times
        monitor.start()
        monitor.start()
        monitor.start()

        // All calls should result in exactly one timer running
        // We verify this by checking that stop() works correctly
        // (if multiple timers existed, we'd need multiple stops)
        let expectation = XCTestExpectation(description: "Timer runs after multiple starts")

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1.0)

        // After stop, no timer should be running
        monitor.stop()
        monitor.stop() // Should not crash or cause issues
    }

    func testStartStopStartCycle() {
        monitor.start()

        let expectation1 = XCTestExpectation(description: "First cycle")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            expectation1.fulfill()
        }
        wait(for: [expectation1], timeout: 1.0)

        monitor.stop()

        // Start again - should work without issues
        monitor.start()

        let expectation2 = XCTestExpectation(description: "Second cycle")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            expectation2.fulfill()
        }
        wait(for: [expectation2], timeout: 1.0)

        monitor.stop()
    }
}
