//
//  ExtensionDelegate.swift
//  Muse WatchKit Extension
//
//  Created by warren on 11/9/16.
//  Copyright © 2016 Muse. All rights reserved.
//

import WatchKit
import ClockKit



class ExtensionDelegate: NSObject, WKExtensionDelegate {

static let WillResignActive = Notification.Name("WillResignActive")

    func applicationDidFinishLaunching() { Log("⌚︎ \(#function)")
        Timer.delay(5) {
            Complicated.shared.reloadTimelines() // does this get executed ever?
        }
    }

    func applicationWillEnterForeground()  {  Log("⌚︎ \(#function)")
    }

    func applicationDidEnterBackground()  { Log("⌚︎ \(#function)")
    }

    func applicationDidBecomeActive() {  Log("⌚︎ \(#function)")
        // both becomming active and unactive, bug?
    }

    func applicationWillResignActive() {  Log("⌚︎ \(#function)")
        NotificationCenter.default.post(name: ExtensionDelegate.WillResignActive, object: nil)
    }

    func handle(_ backgroundTasks: Set<WKRefreshBackgroundTask>) {  Log("✺ \(#function)")

        for task in backgroundTasks {

            switch task {

            case let t as WKApplicationRefreshBackgroundTask:
                Log("✺ \(#function) type:\(t.classForCoder)")
                Complicated.shared.extendTimelines()
                // case let t as WKSnapshotRefreshBackgroundTask:
                // case let t as WKWatchConnectivityRefreshBackgroundTask:
                // case let t as WKURLSessionRefreshBackgroundTask:

            default: Log("✺ \(#function) type:\(task.classForCoder)")
            }

            task.setTaskCompletedWithSnapshot(false)
        }
    }

}
