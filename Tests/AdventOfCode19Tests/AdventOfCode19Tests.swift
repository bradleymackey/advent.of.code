import XCTest
import class Foundation.Bundle

final class AdventOfCode19Tests: XCTestCase {
    
    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.

        // Some of the APIs that we use below are available in macOS 10.13 and above.
        guard #available(macOS 10.13, *) else {
            return
        }

        let fooBinary = productsDirectory.appendingPathComponent("AdventOfCode19")

        let process = Process()
        process.executableURL = fooBinary

        let pipe = Pipe()
        process.standardOutput = pipe

        try process.run()
        process.waitUntilExit()

        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: .utf8)

        XCTAssertEqual(output, "Hello, world!\n")
    }
    
//    func testCoordinate1() {
//        let c1 = Coordinate(x: 4, y: 4)
//        let c2 = Coordinate(x: 0, y: 0)
//        let pts = c1.exactIntegerPointsBetween(c2, min: .zero, max: Coordinate(x: 4, y: 4))
//        XCTAssert(pts.count == 3)
//    }
//
//    func testCoordinate2() {
//        let c1 = Coordinate(x: 3, y: 2)
//        let c2 = Coordinate(x: 4, y: 0)
//        let pts = c1.exactIntegerPointsBetween(c2, min: .zero, max: Coordinate(x: 4, y: 4))
//        XCTAssert(pts.count == 0)
//    }
//
//    func testCoordinate2() {
//        let c1 = Coordinate(x: 2, y: 2)
//        let c2 = Coordinate(x: 4, y: 2)
//        let pts = c1.exactIntegerPointsBetween(c2, min: .zero, max: Coordinate(x: 4, y: 4))
//        XCTAssert(pts.count == 1)
//    }
//
//    func testCoordinate3() {
//        let c1 = Coordinate(x: 0, y: 2)
//        let c2 = Coordinate(x: 4, y: 0)
//        let pts = c1.exactIntegerPointsBetween(c2, min: .zero, max: Coordinate(x: 4, y: 4))
//        XCTAssert(pts.count == 1)
//    }

    /// Returns path to the built products directory.
    var productsDirectory: URL {
      #if os(macOS)
        for bundle in Bundle.allBundles where bundle.bundlePath.hasSuffix(".xctest") {
            return bundle.bundleURL.deletingLastPathComponent()
        }
        fatalError("couldn't find the products directory")
      #else
        return Bundle.main.bundleURL
      #endif
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
