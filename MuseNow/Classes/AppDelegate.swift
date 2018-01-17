
import UIKit


@objc(MyApplication) class MyApplication: UIApplication {


    var touchScreen = TouchScreen.shared

//    override func sendEvent(_ event: UIEvent) {
//
//        if event.type == .touches,
//            touchScreen.redirectSendEvent(event) {
//        }
//        else {
//            super.sendEvent(event)
//        }
//    }
}
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var didStopActive = false // prevent multiple calls to startActive()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        return true
    }

//    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
//
//        self.window = UIWindow(frame: UIScreen.main.bounds)
//        if let window = self.window {
//            window.rootViewController = OnboardVC()
//            window.makeKeyAndVisible()
//        }
//        return true
//    }

    func applicationWillResignActive(_ application: UIApplication) { Log("⟳☎︎ \(#function)")
        MainVC.shared?.active?.stopActive()
        didStopActive = true
    }
    func applicationDidBecomeActive(_ application: UIApplication) { Log("⟳☎︎ \(#function)")
        if didStopActive {
            didStopActive = false
            MainVC.shared?.active?.startActive()
        }
    }
    func applicationDidEnterBackground(_ application: UIApplication) { Log("⟳☎︎ \(#function)")
    }
    func applicationWillEnterForeground(_ application: UIApplication) { Log("⟳☎︎ \(#function)")
    }
    func applicationWillTerminate(_ application: UIApplication) { Log("⟳☎︎ \(#function)")
    }
}

