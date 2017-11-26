//  Calendar.swift

import Foundation
import EventKit
import UIKit


public class Setting {

    var member = 0
    var set = 0
    var title = "title"

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

    init(set set_:Int, member member_:Int, _ title_:String = "") {

        set = set_
        member = member_
        title = title_
    }

}


