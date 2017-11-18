//  Calendar.swift

import Foundation
import EventKit
import UIKit

@objc(Setting)
public class Setting: NSObject, NSCoding {

    var member = 0
    var set = 0
    var title = "title"

    func isOn() -> Bool {
        return set & member != 0
    }

    func flipSet() {
        set ^= member
    }
    func updateTitle() {} // override

    required public init?(coder decoder: NSCoder) {
        super.init()
        member = decoder.decodeInteger(forKey:"member")
        title  = decoder.decodeObject(forKey:"title") as! String
        set    = decoder.decodeInteger(forKey:"set")
        member = decoder.decodeInteger(forKey:"member")
    }

    public func encode(with aCoder: NSCoder) {

        aCoder.encode(member, forKey: "member")
        aCoder.encode(title,  forKey: "title")
        aCoder.encode(set,    forKey: "set")
        aCoder.encode(member, forKey: "member")
    }

    init(_ index:Int, _ set_:Int, _ title_:String = "") {
        super.init()
        member = 1<<index
        set = set_
        title = title_
        updateTitle()
    }

}

@objc(ShowSetting) // share data format for phone and watch devices
public class ShowSetting: Setting {

    override func updateTitle () {
        let set = ShowSet(rawValue:member)
        if      set.contains(.showCalendar)  { title = "Calendars" }
        else if set.contains(.showReminder)  { title = "Reminders" }
        else if set.contains(.showRoutine)   { title = "Routine" }
        else if set.contains(.showMemo)      { title = "Memos" }
        else                                 { title = "" }
    }

    override func flipSet()  {

        super.flipSet()
        Show.shared.showSet = ShowSet(rawValue:set)

        Actions.shared.doRefresh(/*isSender*/false)
        Settings.shared.initSettings()
        Session.shared.sendMsg(["class"  : "ShowSet",
                                "putSet" :  set])
    }
}

@objc(HearSetting) // share data format for phone and watch devices
public class HearSetting: Setting {

    override func updateTitle () {
        let set = HearSet(rawValue:member)
        if      set.contains(.earbuds) { title = "Earbuds" }
        else if set.contains(.speaker) { title = "Speaker" }
        else                           { title = "" }
    }

    override func flipSet()  {
        super.flipSet()
        Hear.shared.hearSet = HearSet(rawValue:set)
        Hear.shared.updateRoute()
        Settings.shared.initSettings()
        Session.shared.sendMsg(["class"  : "HearSet",
                                "putSet" : Hear.shared.hearSet])
    }
}

@objc(SaySetting) // share data format for phone and watch devices
public class SaySetting: Setting {

     override func updateTitle () {
        let set = SaySet(rawValue:member)
        if      set.contains(.sayMemo  ) { title = "Memo" }
        else if set.contains(.saySpeech) { title = "Speech" }
        else if set.contains(.sayTime  ) { title = "Time" }
        else if set.contains(.sayEvent ) { title = "Event" }
    }

    override func flipSet() {
        super.flipSet()
        Say.shared.saySet = SaySet(rawValue:set)
        Settings.shared.initSettings()
        Session.shared.sendMsg(["class"   : "SaySet",
                                "putSet"  : Say.shared.saySet])

    }

}


