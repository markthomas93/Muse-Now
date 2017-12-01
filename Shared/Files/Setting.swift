//  Calendar.swift

import Foundation
import EventKit
import UIKit

struct SetFrom: OptionSet {
    let rawValue: Int
    static let parent = SetFrom(rawValue: 1 << 0) // 1
    static let child  = SetFrom(rawValue: 1 << 1) // 2
}

public class Setting {

    var member = 0
    var set = 0
    var title = "title"
    var setFrom = SetFrom([.parent,.child])

    func isOn() -> Bool {
        return set & member != 0
    }
    func setOn(_ on:Bool) {
        if on {
            set |= member
        }
        else {
            set |= member
            set ^= member
        }
    }
    func flipSet() -> Bool {
        set ^= member
        return isOn()
    }

    init(set set_:Int, member member_:Int, _ title_:String = "",_ setFrom_:SetFrom = [.parent,.child]) {

        set = set_
        setFrom = setFrom_
        member = member_
        title = title_
    }

}


