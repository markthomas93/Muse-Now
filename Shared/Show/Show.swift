//  Hear.swift
//  Created by warren on 10/20/17.
//  Copyright © 2017 Muse. All rights reserved.

import Foundation
import AVFoundation

class Show: NSObject, DemoBackupDelegate {

    static let shared = Show()

    var calendar = true
    var reminder = true
    var memo     = true
    var routine  = true  // routine on dial
    var routList = false // routine on list
    var routDemo = false // routine demo version

    // DemoBackupDelegate

    var backup: Show!

    func setFrom(_ from:Any) {

        if let from = from as? Show {
            calendar = from.calendar
            reminder = from.reminder
            memo     = from.memo
            routine  = from.routine
            routList = from.routList
            routDemo = from.routDemo
        }
    }

    func setupBackup() {
        backup = Show()
        backup.setFrom(self)
    }
    func setupBeforeDemo() {
        setupBackup()
        calendar = true
        reminder = true
        memo     = true
        routine  = true  // routine on dial
        routList = true // routine on list
        routDemo = true // routine demo version
    }

    func restoreAfterDemo() {
        if let backup = backup {
            setFrom(backup)
        }
    }

    // Session 

    func parseMsg(_ msg: [String : Any])  {

        if let _ = msg["get"] {
        }
        else  {

            if let on = msg["calendar"] as? Bool { calendar = on ; TreeNodes.shared.setValue(on, forKey: "show.calendar")}
            if let on = msg["reminder"] as? Bool { reminder = on ; TreeNodes.shared.setValue(on, forKey: "show.reminder")}
            if let on = msg["memo"]     as? Bool { memo     = on ; TreeNodes.shared.setValue(on, forKey: "show.memo")}
            if let on = msg["routine"]  as? Bool { routine  = on ; TreeNodes.shared.setValue(on, forKey: "show.routine")}
            if let on = msg["routList"] as? Bool { routList = on ; TreeNodes.shared.setValue(on, forKey: "show.routList")}
            if let on = msg["routDemo"] as? Bool { routDemo = on ; TreeNodes.shared.setValue(on, forKey: "show.routDemo")}

            Actions.shared.doRefresh(false)
            #if os(iOS)
            PagesVC.shared.menuVC.tableView.reloadData()
            #endif
        }
    }


    public func doShowAction(_ act: DoAction, _ value:Float, _ isSender:Bool) {

        let on = value > 0

        func updateClass(_ className:String, _ path:String) {
            TreeNodes.setOn(on,path)
            Actions.shared.doRefresh(/*isSender*/false)
            if isSender {
                Session.shared.sendMsg(["class" : className, path : on])
            }
        }

        switch act {
        case .showCalendar:  calendar = on ; updateClass("Show","menu.events")
        case .showReminder:  reminder = on ; updateClass("Show","menu.events.reminders")
        case .showMemo:      memo     = on ; updateClass("Show","menu.memos")
        case .showRoutine:   routine  = on ; updateClass("Show","menu.routine")
        case .showRoutList:  routList = on ; updateClass("Show","menu.routine.routList")
        default: break
        }
     }

 }
