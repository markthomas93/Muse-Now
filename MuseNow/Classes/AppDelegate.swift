
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var didStopActive = false // prevent multiple calls to startActive()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        return true
    }
    func applicationWillResignActive(_ application: UIApplication) { printLog("⟳☎︎ \(#function)")
        Active.shared.stopActive()
        didStopActive = true
    }
    func applicationDidBecomeActive(_ application: UIApplication) { printLog("⟳☎︎ \(#function)")
        if didStopActive {
            didStopActive = false
            Active.shared.startActive()
        }
    }
    func applicationDidEnterBackground(_ application: UIApplication) { printLog("⟳☎︎ \(#function)")
    }
    func applicationWillEnterForeground(_ application: UIApplication) { printLog("⟳☎︎ \(#function)")
    }
    func applicationWillTerminate(_ application: UIApplication) { printLog("⟳☎︎ \(#function)")
    }
}

