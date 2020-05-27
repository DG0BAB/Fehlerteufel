import XCTest
@testable import Fehlerteufel

final class FehlerteufelTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(backchat().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
