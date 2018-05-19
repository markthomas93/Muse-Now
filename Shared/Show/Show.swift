//  Hear.swift
//  Created by warren on 10/20/17.
//  Copyright © 2017 Muse. All rights reserved.

import Foundation
import AVFoundation

struct ShowSet: OptionSet {
    let rawValue: Int
    static let calendar = ShowSet(rawValue: 1 << 0) //  1
    static let reminder = ShowSet(rawValue: 1 << 1) //  2
    static let memo     = ShowSet(rawValue: 1 << 2) //  4
    static let routine  = ShowSet(rawValue: 1 << 3) //  8 -- routine on dial
    static let routList = ShowSet(rawValue: 1 << 4) //  16 -- routine on list
    static let routDemo = ShowSet(rawValue: 1 << 5) //  32 -- routine demo version
}

class Show {

    static let shared = Show()
    var showSet = ShowSet([.calendar,.reminder,.routine,.memo])

    func canShow(_ member:ShowSet) -> Bool {
        return showSet.contains(member)
    }
    func updateSetFromSession(_ showSet_:ShowSet) {
        showSet = showSet_
        Settings.shared.updateShowSet(showSet_)
    }

    func getMenus() -> [StrAct] {

        var strActs = [StrAct]()
        strActs.append(showSet.contains(.calendar) ? StrAct("hide calendar" , .hideCalendar) : StrAct("show calendar" , .showCalendar))
        strActs.append(showSet.contains(.reminder) ? StrAct("hide reminder" , .hideReminder) : StrAct("show reminder" , .showReminder))
        strActs.append(showSet.contains(.memo)     ? StrAct("hide memo"     , .hideMemo)     : StrAct("show memo"     , .showMemo))
        //strActs.append(showSet.contains(.routine)  ? StrAct("hide routine"  , .hideRoutine)  : StrAct("show routine"  , .showRoutine))
        return strActs
    }

    public func doShowAction(_ act: DoAction, isSender: Bool = false) {

        switch act {

        case .hideCalendar:  showSet.remove(.calendar)
        case .hideReminder:  showSet.remove(.reminder)
        case .hideMemo:      showSet.remove(.memo)
        case .hideRoutine:   showSet.remove(.routine)
        case .hideRoutList:  showSet.remove(.routList)

        case .showCalendar:  showSet.insert(.calendar)
        case .showReminder:  showSet.insert(.reminder)
        case .showMemo:      showSet.insert(.memo)
        case .showRoutine:   showSet.insert(.routine)
        case .showRoutList:  showSet.insert(.routList)

        default: break
        }
        Settings.shared.settingsFromMemory()
        Actions.shared.doRefresh(/*isSender*/false)

        if isSender {
            Session.shared.sendMsg(["class"  : "ShowSet",
                                    "putSet" : showSet.rawValue])
        }

    }

 }
