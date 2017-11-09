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
        if      member.contains(.earbuds) { title = "earbuds" }
        else if member.contains(.speaker) { title = "speaker" }
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
        Session.shared.sendMsg(["class"       : "HearVia",
                                "putOptions"  :  Hear.shared.options.rawValue])
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

        if      member.contains(.sayMemo     ) { title = "Memo" }
        else if member.contains(.saySpeech   ) { title = "Speech" }
        else if member.contains(.sayTimeNow  ) { title = "Time Now" }
        else if member.contains(.sayTimeUntil) { title = "Time Until" }
        else if member.contains(.sayDayOfWeek) { title = "Day of Week" }
        else if member.contains(.sayTimeHour ) { title = "Time Hour" }
        else if member.contains(.sayEventTime) { title = "Event Time" }
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
