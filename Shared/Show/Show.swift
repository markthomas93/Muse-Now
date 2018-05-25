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

   
    public func doShowAction(_ act: DoAction) {

        func continueAction() {
            Settings.shared.updateShowSet(showSet)
            Actions.shared.doRefresh(/*isSender*/false)

            Session.shared.sendMsg(["class"  : "ShowSet",
                                    "putSet" : showSet.rawValue])
        }

        switch act {

        case .hideCalendar:  showSet.remove(.calendar)
        case .showCalendar:  showSet.insert(.calendar)

        case .hideReminder:  showSet.remove(.reminder)
        case .showReminder:  showSet.insert(.reminder)

        case .hideMemo:      showSet.remove(.memo)
        case .showMemo:      showSet.insert(.memo)

        case .hideRoutine:   showSet.remove(.routine)
        case .showRoutine:   showSet.insert(.routine)
            
        case .hideRoutList:  showSet.remove(.routList)
        case .showRoutList:  showSet.insert(.routList)
            
        default: break
        }
        switch act {
        case .hideRoutine,
             .hideRoutList,
             .showRoutine,
             .showRoutList:

            Routine.shared.archiveRoutine {
                continueAction()
            }
        default: continueAction()
        }

     }

 }
