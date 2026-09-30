import XCTest
@testable import twofortyeight

final class MenuUITestSeedTests: XCTestCase {
    private var defaults: UserDefaults!
    private var suite: String!

    override func setUp() {
        suite = "MenuUITestSeedTests." + UUID().uuidString
        defaults = UserDefaults(suiteName: suite)
    }

    override func tearDown() {
        defaults.removePersistentDomain(forName: suite)
    }

    func testExplicitArgumentSeedsTheApprovedStartingState() {
        XCTAssertTrue(MenuUITestSeed.apply(arguments: ["app", "--menu-ui-seed"], defaults: defaults))
        XCTAssertEqual(defaults.integer(forKey: "score"), 16)
        XCTAssertEqual(defaults.integer(forKey: "bestScore"), 64)
        XCTAssertEqual(defaults.object(forKey: "onGoingGame") as? [[Int]], [
            [2, 4, 0, 0], [0, 8, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0]
        ])
    }

    func testOrdinaryLaunchLeavesSavedGameUntouched() {
        defaults.set(32, forKey: "score")
        defaults.set(128, forKey: "bestScore")
        defaults.set([[16]], forKey: "onGoingGame")
        XCTAssertFalse(MenuUITestSeed.apply(arguments: ["app"], defaults: defaults))
        XCTAssertEqual(defaults.integer(forKey: "score"), 32)
        XCTAssertEqual(defaults.integer(forKey: "bestScore"), 128)
        XCTAssertEqual(defaults.object(forKey: "onGoingGame") as? [[Int]], [[16]])
    }

    func testSeedPreservesUnrelatedPreferences() {
        defaults.set("keep", forKey: "unrelatedPreference")
        XCTAssertTrue(MenuUITestSeed.apply(arguments: ["--menu-ui-seed"], defaults: defaults))
        XCTAssertEqual(defaults.string(forKey: "unrelatedPreference"), "keep")
    }
}
