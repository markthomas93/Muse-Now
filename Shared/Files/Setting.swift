//  Calendar.swift

import Foundation
import EventKit
import UIKit

/**
 Allow mark to be set from parent and/or child
 - parent: toggle ✓/☐ will set all children ✓/☐
 - child: toggle  ✓/☐ will parent to  ✓/-/☐
 */
struct SetFrom: OptionSet, Codable {
    let rawValue: UInt
    static let ignore = SetFrom(rawValue: 1 << 0) // 1
    static let parent = SetFrom(rawValue: 1 << 1) // 2
    static let child  = SetFrom(rawValue: 1 << 2) // 4
}

/**
 Optional info disclosure upon first expand
 - noInfo: do not show "i" icon
 - newInfo: white icon, auto show info on expand
 - oldInfo: gray icon, only show when touching icon
 */
enum ShowInfo: Int, Codable { case

    infoNone,       // no info attached to this celll
    information,    // not yet touched, so play bubble before expanding
    construction,
    purchase
}

public class TreeSetting: Codable {
    var isOn = true
    var setFrom = SetFrom([])   // modifyable from { none,child,parent,both }
    var showInfo = ShowInfo.infoNone
    var action = DoAction.unknown

    func flipSet() -> Bool {
        isOn = !isOn
        if action != .unknown {
            Actions.shared.doAction(action, value: isOn ? 1 : 0, isSender:true)
        }
        return isOn
    }

    init(_ isOn_:Bool,
         _ setFrom_: SetFrom = [.parent,.child],
         _ showInfo_: ShowInfo = .infoNone,
         act: DoAction = .unknown) {

        isOn     = isOn_
        setFrom  = setFrom_
        showInfo = showInfo_
        action   = act
    }

}


