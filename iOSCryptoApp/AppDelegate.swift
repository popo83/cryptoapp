import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        window = UIWindow(frame: UIScreen.main.bounds)
        
        // Follow system appearance (light/dark mode)
        if #available(iOS 13.0, *) {
            window?.overrideUserInterfaceStyle = .unspecified
        }
        
        let authVC = AuthenticationViewController()
        window?.rootViewController = authVC
        window?.makeKeyAndVisible()
        
        return true
    }
}
