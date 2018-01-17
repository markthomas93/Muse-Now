import UIKit
import WatchKit
import EventKit


public enum DoAction : Int { case

    unknown,
    gotoEvent, gotoFuture,

    // say
    saySpeech, skipSpeech,
    sayMemo,  skipMemo,
    sayTime,  skipTime,
    sayEvent, skipEvent,
    speakLow, speakMedium, speakHigh,

    // hear
    hearEarbuds, hearSpeaker,
    muteEarbuds, muteSpeaker,

    // tour
    tourAll, tourMain, tourMenu, tourOnboard, stopTour,

    // show
    showCalendar, hideCalendar,
    showReminder, hideReminder,
    showRoutine,  hideRoutine,
    showMemo,     hideMemo,

    dialColor,

    showEvents, showAlarms, showMarks,showTime,
    markOn, markOff,
    memoMoveAll, markClearAll,
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
    var tableDelegate : MuseTableDelegate?
    var strActs       = [StrAct]()
    var suggestions   = [String]()

    func dialColor(_ fade:Float, isSender: Bool)  {
        
        scene?.uFade?.floatValue = fade
        
        if isSender {

            Session.shared.sendMsg( ["class" : "Actions", "dialColor" : fade])
            Settings.shared.updateColor(fade)
        }
    }

    func doSetTitle(_ title_: String) {
        #if os(watchOS)
            let root = WKExtension.shared().rootInterfaceController!
            root.setTitle(title_)
        #endif
    }
    
    /**
     Every minute, check to see if current time changes its relative position
     - via: active.doMinuteTimerTick
     */

    func doMinuteTimerTick() {
        if MuEvents.shared.timeEvent != nil {
            MuEvents.shared.minuteTimerTick()
            Dots.shared.updateTime(event: MuEvents.shared.timeEvent)
            if let table = tableDelegate {
                table.updateTimeEvent()
            }
        }
    }
    
    /**
     Rebuild UI
     - via: doAction
     - via: Active.minuteTimerTick
     - via: Cals.parseMsg
     - via: FileMsg.parseMsg
     */
    func doRefresh(_ isSender:Bool) {

        scene?.pauseScene()

        Settings.shared.unarchiveSettings {

            MuEvents.shared.updateEvents() {

                self.scene?.updateSceneFinish()
                Dots.shared.updateTime(event: MuEvents.shared.timeEvent)
                if let table = self.tableDelegate {

                    table.updateTable(MuEvents.shared.events)
                    table.updateTimeEvent()
                    if let timeEvent = MuEvents.shared.timeEvent {
                        table.scrollSceneEvent(timeEvent)
                    }
                }
                #if os(watchOS)
                    Crown.shared.updateCrown()
                #endif
            }
             Settings.shared.sendSyncFile()
        }
        
        if isSender {
            
            Session.shared.sendMsg(
                ["class"   : "Actions",
                 "refresh" : "yo"])
        }
    }

    func doAddEvent(_ event:MuEvent, isSender:Bool) {
        
        scene.pauseScene()
        MuEvents.shared.addEvent(event)
        if let table = tableDelegate {
            table.updateTable(MuEvents.shared.events)
        }
        scene.updateSceneFinish()
        
        if isSender {
            if let data = try? JSONEncoder().encode(event) {
                Session.shared.sendMsg(
                    ["class" : "MuseEvent",
                     "addEvent" : data])
            }
        }
    }
    
    func doUpdateEvent(_ event:MuEvent, isSender: Bool) {
        
        scene.pauseScene()
        MuEvents.shared.updateEvent(event)
        tableDelegate?.updateTable(MuEvents.shared.events)
        scene.updateSceneFinish()
        if event.type == .memo {
            Memos.shared.updateMemoArchive()
        }
        if isSender,
            let data = try? JSONEncoder().encode(event) {
            Session.shared.sendMsg(["class"       : "MuseEvent",
                                    "updateEvent" : data])
        }
        else {
            doAction(.gotoEvent, event)
        }
    }
    
    func doToggleMark() { //Log("✓ \(#function)")
        
        Active.shared.startMenuTime()
        let dots = Dots.shared

        // via phoneCrown
        if let table = tableDelegate {
            
            let (event,isOn) = table.toggleCurrentCell()
            let act = isOn ? DoAction.markOn : DoAction.markOff
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
                
                let act = event.mark ? DoAction.markOff : DoAction.markOn
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
    func updateMenuActions() {

        strActs.removeAll()

        strActs.append(contentsOf:Hear.shared.getMenus())
        strActs.append(contentsOf:Show.shared.getMenus())
        strActs.append(contentsOf:Say.shared.getMenus())
        
        strActs.append(StrAct("clear all marks",.markClearAll))
        strActs.append(StrAct("clear all memos",.memoMoveAll))
        strActs.append(StrAct("refresh",.refresh))
    }

    func getSuggestions() -> [String] {
        updateMenuActions()
        var suggestions = [String]()
        for item in Actions.shared.strActs {
            suggestions.append(item.str)
        }
        return suggestions
    }

    /**
     Dispatch commands to Show, Say, Hear, Dots, Anim
     - via: Actions.[doUpdateEvent, doToggleMark]
     - via: Session.parseMsg["Action":]
     - via: EventCell.touchMark
     */
    func doAction(_ act: DoAction, _ event:MuEvent! = nil, _ index:Int = 0, isSender:Bool = false) {
        
        Log("⌘ \(#function):\(act) event:\(event?.title ?? "nil")")
        
        switch act {
        case  // show
        .showCalendar, .hideCalendar,
        .showReminder, .hideReminder,
        .showRoutine,  .hideRoutine,
        .showMemo,     .hideMemo:

            Show.shared.doShowAction(act, isSender: true)

        case .tourAll, .tourMain, .tourMenu, .tourOnboard, .stopTour:
            #if os(iOS)
                BubbleTour.shared.doTourAction(act)
            #endif
        // speech to text volume
        case .sayMemo, .skipMemo,
             .sayTime, .skipTime,
             .sayEvent, .skipEvent,
             .speakLow, .speakMedium, .speakHigh:

            Say.shared.doSayAction(act, isSender:true)

        case  .hearEarbuds, .hearSpeaker,
              .muteEarbuds, .muteSpeaker:

            Hear.shared.doHearAction(act, isSender:true)

        // mark a dot
        case .markOn, .markOff, .markClearAll, .noteRemove, .noteAdd:

            markAction(act, event, index, isSender)

        case .gotoEvent:

            Dots.shared.gotoEvent(event)
            Anim.shared.touchDialGotoTime(event?.bgnTime ?? 0)

             // animate dial to show whole week
        case .gotoFuture:
            Anim.shared.wheelTime = 0
            Anim.shared.animNow = .futrWheel
            Anim.shared.userDotAction()

        case .memoMoveAll:  markAction(act, event, index, isSender)
        /**/                Memos.shared.moveAll()
        /**/                doRefresh(isSender)
            
        case .refresh:      doRefresh(isSender)
            
        case .debugOn:      scene.debugUpdate = true
        case .debugOff:     scene.debugUpdate = false
    
        default: break
        }
    }

    /**
     Translate Watch STT to command
    - via WatchCon.Record.recordMenuFinish
     */
    func parseString(_ str: String, _ event: MuEvent!,_ index: Int, isSender:Bool) {
        
        Log("⌘ \(#function):\(str)")
        
        let loStr = str.lowercased()
        
        for strAct in strActs {
            if loStr.contains(strAct.str) {
                doAction(strAct.act, event, index, isSender: isSender)
                return Haptic.play(.success)
            }
        }
        // Haptic.play(.failure)
    }
    
    /**
     Dispatch a command
     - via: EventTable+Select.(toggleCurrentCell actionTap)
     - via: WatchCon.menu(Mark Clear)Action
     */
    func markAction(_ act:DoAction, _ event:MuEvent!, _ index: Int, _ isSender:Bool) {
        
        Log("✓ \(#function) \(act) \(event != nil ? event.title : "nil") isSender:\(isSender)")
        
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
        case .markOn:       markEvent = dot.setMark(true, event)
        case .markOff:      markEvent = dot.setMark(false, event)
        case .markClearAll: break //!!!! Dots.shared.hideEventsWith(type:.mark)
        case .memoMoveAll: Dots.shared.hideEventsWith(type:.memo)
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

    func sendAction(_ act:DoAction, _ event:MuEvent!, _ time: TimeInterval) {
        
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
