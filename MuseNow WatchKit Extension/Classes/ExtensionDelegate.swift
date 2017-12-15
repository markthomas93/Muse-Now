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

    func applicationDidFinishLaunching() { Log("⟳⌚︎ \(#function)")
        let _ = Timer.scheduledTimer(withTimeInterval: 5, repeats: false, block: {_ in
            Complicated.shared.reloadTimelines()
        })
    }

    func applicationWillEnterForeground()  {  Log("⟳⌚︎ \(#function)")
    }

    func applicationDidEnterBackground()  { Log("⟳⌚︎ \(#function)")
    }

    func applicationDidBecomeActive() {  Log("⟳⌚︎ \(#function)")
        // both becomming active and unactive, bug?
    }

    func applicationWillResignActive() {  Log("⟳⌚︎ \(#function)")
        // menus or other interruptions
    }

    func handle(_ backgroundTasks: Set<WKRefreshBackgroundTask>) {  Log("⟳⌚︎ \(#function)")

        for task in backgroundTasks {

            switch task {

            case let task as WKApplicationRefreshBackgroundTask:

                Log("⟳✺ \(#function) type:\(task.classForCoder)")
                Complicated.shared.extendTimelines()

//            case let t as WKSnapshotRefreshBackgroundTask:
//            case let t as WKWatchConnectivityRefreshBackgroundTask:
//            case let t as  WKURLSessionRefreshBackgroundTask:

            default:
                Log("⟳✺ \(#function) type:\(task.classForCoder)")
            }
             task.setTaskCompletedWithSnapshot(false)
        }
    }

}
