//  Calendar.swift

import Foundation
import EventKit
import UIKit

@objc(Setting)
public class Setting: NSObject {

    var title = "title"
    var isOn  = true
    func flipSet() { }
}

@objc(ShowSetting) // share data format for phone and watch devices
public class ShowSetting: Setting, NSCoding {

    var member = ShowSet([])

    required public init?(coder decoder: NSCoder) {
        super.init()
        member = decoder.decodeObject(forKey:"member") as! ShowSet
        title  = decoder.decodeObject(forKey:"title") as! String
        isOn   = decoder.decodeBool  (forKey:"isOn")
    }

    public func encode(with aCoder: NSCoder) {
        aCoder.encode(member, forKey: "member")
        aCoder.encode(title,  forKey: "title")
        aCoder.encode(isOn,   forKey: "isOn")
    }

    func updateTitle () {
        if      member.contains(.showCalendar)  { title = "Calendars" }
        else if member.contains(.showReminder)  { title = "Reminders" }
        else if member.contains(.showRoutine)   { title = "Routine" }
        else if member.contains(.showMemo)      { title = "Memos" }
        else                                    { title = "" }
    }

    init(_ index:Int) {
        super.init()
        member = ShowSet(rawValue:1<<index)
        isOn = Show.shared.showSet.contains(member)
        updateTitle()
    }

    override func flipSet()  {

        isOn = !isOn

        if isOn { Show.shared.showSet.insert(member) }
        else    { Show.shared.showSet.remove(member) }

        Actions.shared.doRefresh(/*isSender*/false)
        Settings.shared.initSettings()
        Session.shared.sendMsg(["class"  : "ShowSet",
                                "putSet" :  Show.shared.showSet.rawValue])
    }
}



@objc(HearSetting) // share data format for phone and watch devices
public class HearSetting: Setting, NSCoding {
    
    var member = HearSet([])

    required public init?(coder decoder: NSCoder) {
        super.init()
        member = decoder.decodeObject(forKey:"member") as! HearSet
        title  = decoder.decodeObject(forKey:"title") as! String
        isOn   = decoder.decodeBool  (forKey:"isOn")
    }
    
    public func encode(with aCoder: NSCoder) {
        aCoder.encode(member, forKey:"member")
        aCoder.encode(title,   forKey:"title")
        aCoder.encode(isOn,    forKey:"isOn")
    }

    func updateTitle () {
        if      member.contains(.earbuds) { title = "Earbuds" }
        else if member.contains(.speaker) { title = "Speaker" }
        else                              { title = "" }
    }

    init(_ index:Int) {
        super.init()
        member = HearSet(rawValue:1<<index)
        isOn = Hear.shared.options.contains(member)
        updateTitle()
    }

    override func flipSet()  {
        isOn = !isOn
        if isOn {  Hear.shared.options.insert(member) }
        else    {  Hear.shared.options.remove(member) }
        Hear.shared.updateRoute()
        Settings.shared.initSettings()
        Session.shared.sendMsg(["class"       : "HearSet",
                                "putSet"  :  Hear.shared.options.rawValue])
    }
}

@objc(SaySetting) // share data format for phone and watch devices

public class SaySetting: Setting {
    
    var member = SaySet([.sayMemo])
    
    required public init?(coder decoder: NSCoder) {
        super.init()
        member = decoder.decodeObject(forKey:"member") as! SaySet
        title  = decoder.decodeObject(forKey:"title") as! String
        isOn   = decoder.decodeBool  (forKey:"isOn")
    }
    
    public func encode(with aCoder: NSCoder) {

        aCoder.encode(member, forKey:"member")
        aCoder.encode(title,   forKey:"title")
        aCoder.encode(isOn,    forKey:"isOn")
    }
    
    func updateTitle () {

        if      member.contains(.sayMemo  ) { title = "Memo" }
        else if member.contains(.saySpeech) { title = "Speech" }
        else if member.contains(.sayTime  ) { title = "Time" }
        else if member.contains(.sayEvent ) { title = "Event" }
    }
    
    init(_ index:Int) {
        super.init()
        member = SaySet(rawValue:1<<index)
        isOn = Say.shared.saySet.contains(member)
        updateTitle()
    }
    
    override func flipSet() {
        isOn = !isOn
        if isOn { Say.shared.saySet.insert(member) }
        else    { Say.shared.saySet.remove(member) }
        Settings.shared.initSettings()
        Session.shared.sendMsg(["class"   : "SaySet",
                                "putSet"  : Say.shared.saySet.rawValue])

    }
    
}
