#if DEBUG
import Foundation

enum MenuUITestSeed {
    @discardableResult
    static func apply(arguments: [String], defaults: UserDefaults) -> Bool {
        guard arguments.contains("--menu-ui-seed") else { return false }
        defaults.set(16, forKey: "score")
        defaults.set(64, forKey: "bestScore")
        defaults.set([
            [2, 4, 0, 0], [0, 8, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0]
        ], forKey: "onGoingGame")
        return true
    }
}
#endif
