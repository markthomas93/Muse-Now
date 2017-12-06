
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) { printLog("⟳☎︎ \(#function)")
        Active.shared.stopActive()
    }

    private var observer: NSKeyValueObservation?

    func applicationDidBecomeActive(_ application: UIApplication) { printLog("⟳☎︎ \(#function)")
        
        Active.shared.startActive()
         printLog("◰ \(type(of: self)) \(UIScreen.main.bounds) ")
        observer = UIScreen.main.observe(\.bounds) { [weak self] object, change in
            printLog("◰ \(type(of: self)) \(object) \(change)")
        }
    }

    func applicationDidEnterBackground(_ application: UIApplication) { printLog("⟳☎︎ \(#function)")
    }
    func applicationWillEnterForeground(_ application: UIApplication) { printLog("⟳☎︎ \(#function)")
    }
    func applicationWillTerminate(_ application: UIApplication) { printLog("⟳☎︎ \(#function)")
    }
}

