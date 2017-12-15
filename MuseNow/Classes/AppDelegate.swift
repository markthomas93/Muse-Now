
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var didStopActive = false // prevent multiple calls to startActive()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        return true
    }
    func applicationWillResignActive(_ application: UIApplication) { Log("⟳☎︎ \(#function)")
        Active.shared.stopActive()
        didStopActive = true
    }
    func applicationDidBecomeActive(_ application: UIApplication) { Log("⟳☎︎ \(#function)")
        if didStopActive {
            didStopActive = false
            Active.shared.startActive()
        }
    }
    func applicationDidEnterBackground(_ application: UIApplication) { Log("⟳☎︎ \(#function)")
    }
    func applicationWillEnterForeground(_ application: UIApplication) { Log("⟳☎︎ \(#function)")
    }
    func applicationWillTerminate(_ application: UIApplication) { Log("⟳☎︎ \(#function)")
    }
}

