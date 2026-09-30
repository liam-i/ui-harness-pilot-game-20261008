import XCTest

final class MenuUITests: XCTestCase {
    private let app = XCUIApplication()
    private let seedBoard = [[2, 4, 0, 0], [0, 8, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0]]

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    private func launchSeed() {
        if app.state != .notRunning { app.terminate() }
        app.launchArguments = ["--menu-ui-seed", "-AppleLanguages", "(en)", "-AppleLocale", "en_US"]
        app.launch()
        XCTAssertTrue(app.buttons["menuButton"].waitForExistence(timeout: 5))
    }

    private func waitFor(_ element: XCUIElement, _ predicate: NSPredicate) {
        let ready = expectation(for: predicate, evaluatedWith: element)
        wait(for: [ready], timeout: 5)
    }

    private func assertScores(_ score: Int, _ best: Int) {
        let scoreNode = app.staticTexts["scoreValue"]
        waitFor(scoreNode, NSPredicate(format: "label == %@", String(score)))
        XCTAssertEqual(scoreNode.label, String(score))
        XCTAssertEqual(app.staticTexts["bestValue"].label, String(best))
    }

    private func board() -> [[Int]] {
        (0..<4).map { row in
            (0..<4).map { column in
                let cell = app.descendants(matching: .any)["tile-\(row)-\(column)"].firstMatch
                XCTAssertTrue(cell.exists, "Missing tile \(row),\(column)")
                guard let value = Int(cell.label) else {
                    XCTFail("Non-numeric tile label: \(cell.label)")
                    return -1
                }
                return value
            }
        }
    }

    private func openMenu() {
        app.buttons["menuButton"].tap()
        XCTAssertTrue(app.buttons["newGameButton"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.buttons["newGameButton"].isHittable)
        XCTAssertTrue(app.buttons["resetBestScoreButton"].isHittable)
    }

    private func dismissMenu() {
        app.swipeDown(velocity: .fast)
        waitFor(app.buttons["menuButton"], NSPredicate(format: "isHittable == true"))
        XCTAssertFalse(app.buttons["newGameButton"].exists)
    }

    private func capture(_ id: String) {
        XCTContext.runActivity(named: id) { activity in
            let shot = XCTAttachment(screenshot: app.screenshot())
            shot.name = id
            shot.lifetime = .keepAlways
            activity.add(shot)
        }
    }

    func testApprovedMenuLayout() {
        launchSeed()
        openMenu()
        let primary = app.buttons["newGameButton"]
        let secondary = app.buttons["resetBestScoreButton"]
        for button in [primary, secondary] {
            XCTAssertEqual(button.frame.width, 312, accuracy: 1)
            XCTAssertEqual(button.frame.height, 64, accuracy: 1)
            XCTAssertTrue(app.windows.firstMatch.frame.contains(button.frame))
            XCTAssertTrue(button.isHittable)
        }
        XCTAssertEqual(secondary.frame.minY - primary.frame.maxY, 16, accuracy: 1)
        let title = app.staticTexts["menuTitle"]
        let brand = app.staticTexts["menuBrand"]
        let hint = app.staticTexts["menuHint"]
        XCTAssertEqual(title.label, "MENU")
        XCTAssertEqual(brand.label, "2048")
        XCTAssertEqual(hint.label, "Swipe down to return")
        for text in [title, brand, hint] {
            XCTAssertTrue(text.isHittable)
            XCTAssertTrue(app.windows.firstMatch.frame.contains(text.frame))
            XCTAssertFalse(text.frame.intersects(primary.frame))
            XCTAssertFalse(text.frame.intersects(secondary.frame))
        }
        capture("menu-layout")
        primary.coordinate(withNormalizedOffset: CGVector(dx: 0.02, dy: 0.98)).tap()
        waitFor(app.buttons["menuButton"], NSPredicate(format: "isHittable == true"))
        assertScores(0, 64)
        print("LAYOUT PASS 312x64pt gap16pt; full corner hit target activates NEW GAME")
    }

    func testApprovedMenuBehavior() throws {
        struct Expected: Decodable {
            struct Case: Decodable { let id: String }
            let cases: [Case]
        }
        let path = try XCTUnwrap(Bundle(for: Self.self).url(forResource: "game-expected", withExtension: "json"))
        let expected = try JSONDecoder().decode(Expected.self, from: Data(contentsOf: path))
        XCTAssertEqual(expected.cases.map { $0.id }, ["B01", "B02", "B03", "B04", "B05", "B06", "B07", "B08", "B09"])

        launchSeed()
        assertScores(16, 64)
        XCTAssertEqual(board(), seedBoard)
        capture("B01")
        print("CASE B01 PASS score=16 best=64 board=seed")

        openMenu()
        XCTAssertTrue(app.staticTexts["MENU"].exists)
        XCTAssertEqual(app.buttons["newGameButton"].label, "NEW GAME")
        XCTAssertEqual(app.buttons["resetBestScoreButton"].label, "RESET BEST SCORE")
        capture("B02")
        print("CASE B02 PASS menu visible; state checked after dismiss")

        dismissMenu()
        assertScores(16, 64)
        XCTAssertEqual(board(), seedBoard)
        capture("B03")
        print("CASE B03 PASS down gesture returns unchanged board")

        openMenu()
        app.buttons["resetBestScoreButton"].tap()
        let alert = app.alerts.firstMatch
        XCTAssertTrue(alert.waitForExistence(timeout: 5))
        XCTAssertTrue(alert.staticTexts["Are you sure you want to erase your best score?"].exists)
        XCTAssertTrue(alert.buttons["Cancel"].isHittable)
        XCTAssertTrue(alert.buttons["Yeah, whatever"].isHittable)
        capture("B04")
        print("CASE B04 PASS original native alert; no mutation checked by cancel")

        alert.buttons["Cancel"].tap()
        waitFor(app.buttons["newGameButton"], NSPredicate(format: "isHittable == true"))
        capture("B05")
        dismissMenu()
        assertScores(16, 64)
        XCTAssertEqual(board(), seedBoard)
        print("CASE B05 PASS Cancel kept menu and original data")

        openMenu()
        app.buttons["resetBestScoreButton"].tap()
        XCTAssertTrue(alert.waitForExistence(timeout: 5))
        alert.buttons["Yeah, whatever"].tap()
        waitFor(app.buttons["menuButton"], NSPredicate(format: "isHittable == true"))
        XCTAssertFalse(app.buttons["newGameButton"].exists)
        assertScores(16, 0)
        XCTAssertEqual(board(), seedBoard)
        capture("B06")
        print("CASE B06 PASS best=0 immediately score=16 board=seed")

        launchSeed()
        assertScores(16, 64)
        XCTAssertEqual(board(), seedBoard)
        openMenu()
        app.buttons["newGameButton"].tap()
        waitFor(app.buttons["menuButton"], NSPredicate(format: "isHittable == true"))
        assertScores(0, 64)
        let newBoard = board()
        let nonzero = newBoard.flatMap { $0 }.filter { $0 != 0 }
        XCTAssertEqual(nonzero.count, 1)
        XCTAssertTrue(nonzero == [2] || nonzero == [4])
        XCTAssertFalse(app.buttons["undoButton"].isEnabled)
        XCTAssertTrue(app.staticTexts["moves: 0"].exists)
        capture("B07")
        print("CASE B07 PASS score=0 best=64 one tile2/4 undo cleared")

        openMenu()
        XCUIDevice.shared.press(.home)
        let background = expectation(for: NSPredicate { _, _ in
            self.app.state == .runningBackground || self.app.state == .runningBackgroundSuspended
        }, evaluatedWith: app)
        wait(for: [background], timeout: 5)
        app.activate()
        waitFor(app.buttons["newGameButton"], NSPredicate(format: "isHittable == true"))
        capture("B08")
        dismissMenu()
        assertScores(0, 64)
        XCTAssertEqual(board(), newBoard)
        print("CASE B08 PASS same-process menu restored; game unchanged")
    }
}
