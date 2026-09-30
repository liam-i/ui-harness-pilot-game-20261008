import SwiftUI
import UIKit

struct MenuTokens: Decodable {
    enum LoadError: Error, Equatable { case invalidValues }

    struct RGB: Decodable {
        let value: UInt32

        var color: Color {
            Color(red: Double((value >> 16) & 255) / 255,
                  green: Double((value >> 8) & 255) / 255,
                  blue: Double(value & 255) / 255)
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            let string = try container.decode(String.self)
            let digits = string.dropFirst()
            guard string.first == "#", digits.count == 6,
                  digits.allSatisfy({ "0123456789abcdefABCDEF".contains($0) }),
                  let value = UInt32(digits, radix: 16) else {
                throw DecodingError.dataCorruptedError(in: container, debugDescription: "Expected #RRGGBB color")
            }
            self.value = value
        }
    }

    struct Insets: Decodable {
        let top: CGFloat
        let leading: CGFloat
        let bottom: CGFloat
        let trailing: CGFloat

        var edges: EdgeInsets {
            EdgeInsets(top: top, leading: leading, bottom: bottom, trailing: trailing)
        }
    }

    let units: String
    let background: RGB
    let text: RGB
    let muted: RGB
    let sideInset: CGFloat
    let buttonMaxWidth: CGFloat
    let buttonHeight: CGFloat
    let buttonGap: CGFloat
    let buttonTextSize: CGFloat
    let titleSize: CGFloat
    let brandSize: CGFloat
    let hintSize: CGFloat
    let buttonCapInsets: Insets
    let assetScale: Int
    let font: String
    let title: String
    let brand: String
    let hint: String
    let newGame: String
    let resetBestScore: String

    static func load(from url: URL) throws -> MenuTokens {
        try decode(Data(contentsOf: url))
    }

    static func decode(_ data: Data) throws -> MenuTokens {
        let tokens = try JSONDecoder().decode(MenuTokens.self, from: data)
        let positive = [tokens.buttonMaxWidth, tokens.buttonHeight, tokens.buttonTextSize,
                        tokens.titleSize, tokens.brandSize, tokens.hintSize]
        let nonnegative = [tokens.sideInset, tokens.buttonGap, tokens.buttonCapInsets.top,
                           tokens.buttonCapInsets.leading, tokens.buttonCapInsets.bottom,
                           tokens.buttonCapInsets.trailing]
        let labels = [tokens.title, tokens.brand, tokens.hint, tokens.newGame, tokens.resetBestScore]
        guard tokens.units == "pt", tokens.font == "system.rounded", tokens.assetScale == 2,
              positive.allSatisfy({ $0.isFinite && $0 > 0 }),
              nonnegative.allSatisfy({ $0.isFinite && $0 >= 0 }),
              labels.allSatisfy({ !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }) else {
            throw LoadError.invalidValues
        }
        return tokens
    }
}

struct MenuResources {
    enum LoadError: Error, Equatable { case missingTokens, missingImage(String) }

    let tokens: MenuTokens
    let primary: UIImage
    let secondary: UIImage

    static let current: MenuResources = {
        do {
            return try load(bundle: .main)
        } catch {
            fatalError("Cannot load approved menu resources: \(error)")
        }
    }()

    static func load(bundle: Bundle) throws -> MenuResources {
        guard let url = bundle.url(forResource: "menu-tokens", withExtension: "json") else {
            throw LoadError.missingTokens
        }
        let tokens = try MenuTokens.load(from: url)
        guard let primary = UIImage(named: "MenuPrimary", in: bundle, compatibleWith: nil) else {
            throw LoadError.missingImage("MenuPrimary")
        }
        guard let secondary = UIImage(named: "MenuSecondary", in: bundle, compatibleWith: nil) else {
            throw LoadError.missingImage("MenuSecondary")
        }
        return MenuResources(tokens: tokens, primary: primary, secondary: secondary)
    }
}
