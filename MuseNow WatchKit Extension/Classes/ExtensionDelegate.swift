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

    func applicationDidFinishLaunching() { printLog("⟳⌚︎ \(#function)")
        let _ = Timer.scheduledTimer(withTimeInterval: 5, repeats: false, block: {_ in
            Complicated.shared.reloadTimelines()
        })
    }

    func applicationWillEnterForeground()  {  printLog("⟳⌚︎ \(#function)")
    }

    func applicationDidEnterBackground()  { printLog("⟳⌚︎ \(#function)")
    }

    func applicationDidBecomeActive() {  printLog("⟳⌚︎ \(#function)")
        // both becomming active and unactive, bug?
    }

    func applicationWillResignActive() {  printLog("⟳⌚︎ \(#function)")
        // menus or other interruptions
    }

    func handle(_ backgroundTasks: Set<WKRefreshBackgroundTask>) {  printLog("⟳⌚︎ \(#function)")

        for task in backgroundTasks {

            switch task {

            case let task as WKApplicationRefreshBackgroundTask:

                printLog("⟳✺ \(#function) type:\(task.classForCoder)")
                Complicated.shared.extendTimelines()

//            case let t as WKSnapshotRefreshBackgroundTask:
//            case let t as WKWatchConnectivityRefreshBackgroundTask:
//            case let t as  WKURLSessionRefreshBackgroundTask:

            default:
                printLog("⟳✺ \(#function) type:\(task.classForCoder)")
            }
             task.setTaskCompletedWithSnapshot(false)
        }
    }

}
