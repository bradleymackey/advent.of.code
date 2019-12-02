import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(AdventOfCode19Tests.allTests),
    ]
}
#endif
