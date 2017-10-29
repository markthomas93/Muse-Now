import UIKit
import WatchKit
import EventKit


public enum DoAction : Int { case
    unknown, gotoEvent,

    speakOn, speakOff, speakLow, speakMedium, speakHigh, fadeColor,
    memoOn, memoOff,

    hearEarbuds, hearSpeaker, hearRemote, hearAll,
    muteEarbuds, muteSpeaker, muteRemote, muteAll,

    showEvents, showAlarms, showMarks,showTime,
    markAdd, markRemove, markClearAll,
    recClearAll,
    noteAdd, noteRemove,
    //chimeOff, chimeLow, chimeMedium, chimeHigh, chimeOn,
    debugOn, debugOff,
    refresh
}

class StrAct {
    var str: String!
    var act: DoAction!

    init(_ str_:String, _ act_: DoAction) {
        str = str_
        act = act_
    }
}


class Actions {
    
    static let shared = Actions()
    
    var scene         : Scene!
    var tableDelegate : KoTableDelegate?
    var strAct        : [String:DoAction] = [:]
    var menuAct       = [StrAct]()
    var suggestions   = [String]()
    
    init () {
        makeTxtActions()
    }
    

    func fadeColor(_ fade:Float, isSender: Bool) {
        
        scene?.uFade?.floatValue = Float(fade)
        
        if isSender {
            
            Session.shared.sendMsg( ["class"     : "Actions",
                                     "fadeColor" : fade])
            
            Settings.shared.updateAct(.fadeColor, fade)
        }
    }
    //-----------------------------------------
    
    
    func doSetTitle(_ title_: String) {
        #if os(watchOS) //????
            let root = WKExtension.shared().rootInterfaceController!
            root.setTitle(title_)
        #endif
    }
    
    /// every minute, check to see if current time changes its relative position
    /// - via: active.doMinuteTimerTick

    func doMinuteTimerTick() {
        if KoEvents.shared.timeEvent != nil {
            KoEvents.shared.minuteTimerTick()
            Dots.shared.updateTime(event: KoEvents.shared.timeEvent)
            if let table = tableDelegate {
                table.updateTimeEvent()
            }
        }
    }
    
    /// - via: doAction
    /// - via: Active.minuteTimerTick
    /// - via: Cals.parseMsg
    /// - via: FileMsg.parseMsg

    func doRefresh(_ isSender:Bool) {
        
        scene?.pauseScene()
        
        KoEvents.shared.updateEvents() {
            
            self.scene?.updateSceneFinish()
            Dots.shared.updateTime(event: KoEvents.shared.timeEvent)
            if let table = self.tableDelegate {

                table.updateTable(KoEvents.shared.events)
                table.updateTimeEvent()
                if let timeEvent = KoEvents.shared.timeEvent {
                    table.scrollSceneEvent(timeEvent)
                }
            }
            #if os(watchOS)
                Crown.shared.updateCrown()
            #endif
            Settings.shared.unarchiveSettings {
                Settings.shared.synchronize()
            }
        }
        if isSender {
            
            Session.shared.sendMsg(
                ["class"   : "Actions",
                 "refresh" : "yo"])
        }
    }

    func doAddEvent(_ event:KoEvent, isSender:Bool) {
        
        scene.pauseScene()
        KoEvents.shared.addEvent(event)
        if let table = tableDelegate {
            table.updateTable(KoEvents.shared.events)
        }
        scene.updateSceneFinish()
        
        if isSender {
            let data = NSKeyedArchiver.archivedData(withRootObject:event)
            Session.shared.sendMsg(
                ["class" : "KoEvent",
                 "addEvent" : data])
        }
    }
    
      
    func doUpdateEvent(_ event:KoEvent, isSender: Bool) {
        
        scene.pauseScene()
        KoEvents.shared.updateEvent(event)
        tableDelegate?.updateTable(KoEvents.shared.events)
        scene.updateSceneFinish()
        if event.type == .memo {
            Memos.shared.archive()
        }
        if isSender {
            let data = NSKeyedArchiver.archivedData(withRootObject:event)
            Session.shared.sendMsg(["class"       : "KoEvent",
                                    "updateEvent" : data])
        }
        else {
            doAction(.gotoEvent, event)
        }
    }
    
    func doToggleMark() { //printLog("✓ \(#function)")
        
        Active.shared.startMenuTime()
        let dots = Dots.shared

        // via phoneCrown
        if let table = tableDelegate {
            
            let (event,isOn) = table.toggleCurrentCell()
            let act = isOn ? DoAction.markAdd : DoAction.markRemove
            if let event = event {
                doAction(act, event, dots.gotoEvent(event), isSender: true)
            }
            else {
                doAction(act, nil, 0, isSender: true)
            }
             Haptic.play(.success)
        }
            // via watch
        else {
            
            let (event,delta) = dots.getNearestEvent(0)
            let index = Int(dots.dotNow) + delta
            if let event = event {
                
                let act = event.mark ? DoAction.markRemove : DoAction.markAdd
                doAction(act, event, index, isSender: true)
                Haptic.play(.success)
            }
            else {
                print("\(#function) no event found")
            }
        }
    }
    
    //-----------------------------------------
    /**
     create am array of text actions that can be used by either;
        - scrolling menu table that returns text string
        - speech to text string to match
     */
    func makeTxtActions () {

        //addAction(.showEvents, "show events")
        //addAction(.showAlarms, "show alarms")
        //addAction(.showMarks,  "show marks")
        //addAction(.showTime,   "show time")

        strAct["add mark"] = .markAdd

        strAct["remove mark"] = .markRemove
        strAct["clear mark"] = .markRemove
        strAct["clear all marks"] = .markClearAll
        strAct["clear all recordings"] = .recClearAll
        
        // text to speech
        strAct["set speech on"] = .speakOn
        strAct["set speech off"] = .speakOff
        strAct["set speak on"] = .speakOn
        strAct["set speak off"] = .speakOff
        strAct["set volume off"] = .speakOff
        strAct["set volume low"] = .speakLow
        strAct["set volume medium"] = .speakMedium
        strAct["set volume hi"] = .speakHigh
        
        // chimes
        // addAction(.chimeOff,     "set chime off")
        // addAction(.chimeLow,     "set chime low")
        // addAction(.chimeMedium,  "set chime medium")
        // addAction(.chimeHigh,    "set chime high")
        // addAction(.chimeOn,      "set chime on")
        
        // addAction(.debugOn,  "set debug on")
        // addAction(.debugOff, "set debug off")

    }

    func updateMenuActions() {

        menuAct.removeAll()

        menuAct.append(Say.shared.isSayOn
            ? StrAct("set speech off",.speakOff)
            : StrAct("set speech on",.speakOn))

        menuAct.append(StrAct("clear all marks",.markClearAll))
        menuAct.append(StrAct("refresh",.refresh))
    }

    func getSuggestions() -> [String] {
        updateMenuActions()
        var suggestions = [String]()
        for item in Actions.shared.menuAct {
            suggestions.append(item.str)
        }
        return suggestions
    }


     /// - via: doToggleMark, parseMsg,
    func doAction(_ act: DoAction, _ event:KoEvent! = nil, _ index:Int = 0, isSender:Bool = false) {
        
        printLog("⌘ \(#function):\(act) event:\(event?.title ?? "nil")")
        
        switch act {
            
        // speech to text volume
        case .speakOn, .speakOff, .speakLow, .speakMedium, .speakHigh:

            Say.shared.doSpeakAction(act)

        case  .hearEarbuds, .hearSpeaker, .hearRemote, .hearAll,
              .muteEarbuds, .muteSpeaker, .muteRemote, .muteAll:

            Hear.shared.hearVia.doHearAction(act)

        // mark a dot
        case .markAdd, .markRemove, .markClearAll, .noteRemove, .noteAdd:

            markAction(act, event, index, isSender)

        case .gotoEvent:

            Dots.shared.gotoEvent(event)
            Anim.shared.touchDialGotoTime(event?.bgnTime ?? 0)

        case .recClearAll:  markAction(act, event, index, isSender)
        /**/                Memos.shared.clearAll()
        /**/                doRefresh(isSender)
            
        case .refresh:      doRefresh(isSender)
            
        case .debugOn:      scene.debugUpdate = true
        case .debugOff:     scene.debugUpdate = false
    
        default: break
        }
    }

    /// via WatchCon.Record.recordMenuFinish
    func parseString(_ str: String, _ event: KoEvent!,_ index: Int, isSender:Bool) {
        
        printLog("⌘ \(#function):\(str)")
        
        let loStr = str.lowercased()
        
        for (str,act) in strAct {
            if loStr.contains(str) {
                doAction(act, event, index, isSender: isSender)
                Haptic.play(.success)
                return
            }
        }
        // Haptic.play(.failure)
    }
    
    /**
     Dispatch a command
     - via: EventTable+Select.(toggleCurrentCell actionTap)
     - via: WatchCon.menu(Mark Clear)Action
     */
    func markAction(_ act:DoAction, _ event:KoEvent!, _ index: Int, _ isSender:Bool) {
        
        printLog("✓ \(#function) \(act) \(event != nil ? event.title : "nil") isSender:\(isSender)")
        
        let dot = Dots.shared.getDot(index)
        
        // set a time for note that is in the future or past
        if event != nil && event.type == .note {
            if index != 0 {
                event.bgnTime = dot.timeHour
                event.endTime = dot.timeHour
            }
        }
        
        var markEvent = event
        
        switch act {
        case .noteAdd:      markEvent = dot.addNote(event)
        case .noteRemove:   dot.removeEvent(event)
        case .markAdd:      markEvent = dot.setMark(true, event)
        case .markRemove:   markEvent = dot.setMark(false, event)
        case .markClearAll: Dots.shared.hideEventsWith(type:.mark)
        case .recClearAll:  Dots.shared.hideEventsWith(type:.memo)
        default: break
        }
        
        dot.makeRgb()
        scene.updateTextures()
        
        if markEvent != nil {
            Anim.shared.touchDialGotoTime(markEvent!.bgnTime)
        }
        else {
            markEvent = dot.getCurrentEvent()
        }
        Marks.shared.updateAct(act,markEvent)
        if isSender {
            sendAction(act, markEvent, dot.timeHour)
        }
    }

    func sendAction(_ act:DoAction, _ event:KoEvent!, _ time: TimeInterval) {
        
        var msg : [String:Any] = [
            "class"   : "Actions",
            "action"  : "\(act)",
            "dotTime" : time]
        
        if event != nil {
            msg["eventId"] = event.eventId
            msg["bgnTime"] = event.bgnTime
        }
        Session.shared.sendMsg(msg)
    }
    


}
