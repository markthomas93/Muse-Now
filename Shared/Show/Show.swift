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

    public func doShowAction(_ act: DoAction, _ value:Float) {

        let on = value > 0
        func updatePath(_ path:String) { TreeNodes.setOn(on, path, false) }

        switch act {
        case .showCalendar:  calendar = on ; updatePath("menu.events")
        case .showReminder:  reminder = on ; updatePath("menu.events.reminders")
        case .showMemo:      memo     = on ; updatePath("menu.memos")
        case .showRoutine:   routine  = on ; updatePath("menu.routine")
        case .showRoutList:  routList = on ; updatePath("menu.routine.routList")
        default: return
        }
        Actions.shared.doAction(.refresh)
     }

 }
