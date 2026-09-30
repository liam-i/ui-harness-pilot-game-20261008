import XCTest
import UIKit
@testable import twofortyeight

final class MenuResourcesTests: XCTestCase {
    private func approvedData() throws -> Data {
        let url = try XCTUnwrap(Bundle(for: Self.self).url(forResource: "approved-menu-tokens", withExtension: "json"))
        return try Data(contentsOf: url)
    }

    private func changed(_ key: String, to value: Any) throws -> Data {
        var object = try XCTUnwrap(JSONSerialization.jsonObject(with: approvedData()) as? [String: Any])
        object[key] = value
        return try JSONSerialization.data(withJSONObject: object)
    }

    func testLoadReadsApprovedTokens() throws {
        let url = try XCTUnwrap(Bundle(for: Self.self).url(forResource: "approved-menu-tokens", withExtension: "json"))
        let tokens = try MenuTokens.load(from: url)
        XCTAssertEqual(tokens.buttonMaxWidth, 312)
        XCTAssertEqual(tokens.buttonHeight, 64)
        XCTAssertEqual(tokens.background.value, 0xF8F5EB)
        XCTAssertEqual(tokens.title, "MENU")
    }

    func testDecodeUsesSuppliedValues() throws {
        let tokens = try MenuTokens.decode(changed("buttonMaxWidth", to: 280))
        XCTAssertEqual(tokens.buttonMaxWidth, 280)
        let color = try MenuTokens.decode(changed("background", to: "#010203"))
        XCTAssertEqual(color.background.value, 0x010203)
    }

    func testMissingRequiredFieldIsRejected() throws {
        var object = try XCTUnwrap(JSONSerialization.jsonObject(with: approvedData()) as? [String: Any])
        object.removeValue(forKey: "buttonHeight")
        XCTAssertThrowsError(try MenuTokens.decode(JSONSerialization.data(withJSONObject: object))) { error in
            guard case DecodingError.keyNotFound = error else { return XCTFail("Unexpected \(error)") }
        }
    }

    func testMalformedJSONAndColorAreRejected() throws {
        for data in [Data("{".utf8), try changed("background", to: "#GG0000")] {
            XCTAssertThrowsError(try MenuTokens.decode(data)) { error in
                XCTAssertTrue(error is DecodingError)
            }
        }
    }

    func testInvalidLayoutAndResourceMetadataAreRejected() throws {
        let invalid: [(String, Any)] = [("buttonHeight", 0), ("sideInset", -1), ("units", "px"), ("assetScale", 1), ("font", "unknown"), ("title", "")]
        for (key, value) in invalid {
            XCTAssertThrowsError(try MenuTokens.decode(changed(key, to: value))) { error in
                XCTAssertEqual(error as? MenuTokens.LoadError, .invalidValues)
            }
        }
    }

    func testMissingFileReportsTheReadFailure() {
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString + ".json")
        XCTAssertThrowsError(try MenuTokens.load(from: url)) { error in
            XCTAssertEqual((error as NSError).domain, NSCocoaErrorDomain)
            XCTAssertEqual((error as NSError).code, 260)
        }
    }

    func testImportedBundleResourcesAreAvailableBeforeLoading() throws {
        let url = try XCTUnwrap(Bundle.main.url(forResource: "menu-tokens", withExtension: "json"))
        let actual = try Data(contentsOf: url)
        XCTAssertEqual(actual, try approvedData())
        XCTAssertLessThanOrEqual(actual.count, 16 * 1024)
        for name in ["MenuPrimary", "MenuSecondary"] {
            let image = try XCTUnwrap(UIImage(named: name, in: .main, compatibleWith: nil))
            XCTAssertEqual(image.cgImage?.width, 384)
            XCTAssertEqual(image.cgImage?.height, 128)
            XCTAssertEqual(image.scale, 2)
        }
    }

    func testLoadConnectsTokensAndBothActualImages() throws {
        let resources = try MenuResources.load(bundle: .main)
        XCTAssertEqual(resources.tokens.buttonCapInsets.top, 16)
        XCTAssertEqual(resources.primary.cgImage?.width, 384)
        XCTAssertEqual(resources.secondary.cgImage?.height, 128)
        XCTAssertEqual(resources.primary.scale, 2)
        XCTAssertEqual(resources.secondary.scale, 2)
    }

    func testMissingBundleTokensAreRejected() {
        XCTAssertThrowsError(try MenuResources.load(bundle: Bundle(for: Self.self))) { error in
            XCTAssertEqual(error as? MenuResources.LoadError, .missingTokens)
        }
    }

    func testMissingRequiredImageIsRejected() throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString + ".bundle")
        try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: root) }
        try approvedData().write(to: root.appendingPathComponent("menu-tokens.json"))
        let info = ["CFBundleIdentifier": "com.example.menu-missing-image", "CFBundleName": "MenuFixture", "CFBundlePackageType": "BNDL"]
        try PropertyListSerialization.data(fromPropertyList: info, format: .xml, options: 0).write(to: root.appendingPathComponent("Info.plist"))
        let bundle = try XCTUnwrap(Bundle(url: root))
        XCTAssertThrowsError(try MenuResources.load(bundle: bundle)) { error in
            XCTAssertEqual(error as? MenuResources.LoadError, .missingImage("MenuPrimary"))
        }
    }
}
