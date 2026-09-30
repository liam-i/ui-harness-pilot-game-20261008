import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        #if DEBUG
        MenuUITestSeed.apply(arguments: ProcessInfo.processInfo.arguments, defaults: .standard)
        #endif
        return true
    }
}
