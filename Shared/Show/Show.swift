//  Hear.swift
//  Created by warren on 10/20/17.
//  Copyright © 2017 Muse. All rights reserved.

import Foundation
import AVFoundation

struct ShowSet: OptionSet {
    let rawValue: Int
    static let showCalendar = ShowSet(rawValue: 1 << 0) // 1
    static let showReminder = ShowSet(rawValue: 1 << 1) // 2
    static let showRoutine  = ShowSet(rawValue: 1 << 2) // 4
    static let showMemo     = ShowSet(rawValue: 1 << 3) // 8
    static let size = 4
}

class Show {

    static let shared = Show()
    var showSet = ShowSet([.showCalendar,.showReminder,.showRoutine,.showMemo])

    func canShow(_ member:ShowSet) -> Bool {
        return showSet.contains(member)
    }
    func updateSetFromSession(_ showSet_:ShowSet) {
        showSet = showSet_
    }

    func getMenus() -> [StrAct] {

        var strActs = [StrAct]()
        strActs.append(showSet.contains(.showCalendar) ? StrAct("hide calendar" , .showCalendarOff) : StrAct("show calendar" , .showCalendarOn))
        strActs.append(showSet.contains(.showReminder) ? StrAct("hide reminder" , .showReminderOff) : StrAct("show reminder" , .showReminderOn))
        strActs.append(showSet.contains(.showRoutine)  ? StrAct("hide routine"  , .showRoutineOff)  : StrAct("show routine"  , .showRoutineOn))
        strActs.append(showSet.contains(.showMemo)     ? StrAct("hide memo"     , .showMemoOff)     : StrAct("show memo"     , .showMemoOn))
        return strActs
    }

    public func doShowAction(_ act: DoAction, isSender: Bool = false) {

        switch act {

        case .showCalendarOff:  showSet.remove(.showCalendar)
        case .showReminderOff:  showSet.remove(.showReminder)
        case .showRoutineOff:   showSet.remove(.showRoutine)
        case .showMemoOff:      showSet.remove(.showMemo)

        case .showCalendarOn:  showSet.insert(.showCalendar)
        case .showReminderOn:  showSet.insert(.showReminder)
        case .showRoutineOn:   showSet.insert(.showRoutine)
        case .showMemoOn:      showSet.insert(.showMemo)

        default: break
        }

        Actions.shared.doRefresh(/*isSender*/false)

        if isSender {
            Session.shared.sendMsg(["class"  : "ShowSet",
                                    "putSet" : showSet.rawValue])
        }

    }

 }
