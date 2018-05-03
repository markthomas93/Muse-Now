import UIKit
import WatchKit
import EventKit


public enum DoAction : Int { case

    unknown,
    gotoEvent, gotoFuture, gotoRecordOn,

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
    tourAll, tourMain, tourDetail, tourMenu, tourIntro, tourStop,

    // show
    showCalendar, hideCalendar,
    showReminder, hideReminder,
    showRoutine,  hideRoutine,
    showRoutList, hideRoutList,

    showMemo,      hideMemo,
    memoWhereOn,    memoWhereOff,
    memoNod2RecOn, memoNod2RecOff,
    memoCopyAll, memoClearAll,
    dialColor,

    showEvents, showAlarms, showMarks,showTime,
    markOn, markOff, markClearAll,
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

        func refreshEvents() {

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
                if isSender {
                    Session.shared.sendMsg(["class"   : "Actions",
                                            "refresh" : "yo"])
                }
            }
        }

        // begin ---------------------------
        scene?.pauseScene()
        Settings.shared.unarchiveSettings {
            refreshEvents()
        }
    }
   
    func doUpdateEvent(_ event:MuEvent, isSender: Bool) {
        
        scene.pauseScene()
        if !MuEvents.shared.updateEvent(event) {
             MuEvents.shared.addEvent(event)
        }
        tableDelegate?.updateTable(MuEvents.shared.events)
        scene.updateSceneFinish()
        if [.memoRecord,.memoTrans,.memoTrash].contains(event.type) {
            Memos.shared.archiveMemos {}
        }
        if isSender,
            let data = try? JSONEncoder().encode(event) {
            Session.shared.cacheMsg(["class"      : "MuseEvent",
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
        strActs.append(StrAct("clear all memos",.memoClearAll))
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
        .showMemo,     .hideMemo,
        .showRoutine,  .hideRoutine,
        .showRoutList, .hideRoutList:

            Show.shared.doShowAction(act, isSender: true)


        case .tourAll, .tourMain, .tourMenu, .tourDetail, .tourIntro, .tourStop:
            #if os(iOS)
                Tour.shared.doTourAction(act)
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
        case .markOn, .markOff, .markClearAll:

            markAction(act, event, index, isSender)

        case .gotoEvent:

            Dots.shared.gotoEvent(event)
            Anim.shared.touchDialGotoTime(event?.bgnTime ?? 0)

        case .gotoRecordOn:

            Anim.shared.gotoRecordSpoke(on:true)

             // animate dial to show whole week
        case .gotoFuture:

            Anim.shared.wheelTime = 0
            Anim.shared.animNow = .futrWheel
            Anim.shared.userDotAction()

        case .memoCopyAll,   .memoClearAll,
             .memoWhereOn,   .memoWhereOff,
             .memoNod2RecOn, .memoNod2RecOff: Memos.shared.doAction(act, isSender)
            
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
        
        var markEvent = event
        
        switch act {
        case .markOn:       markEvent = dot.setMark(true, event)
        case .markOff:      markEvent = dot.setMark(false, event)
        case .markClearAll: break //!!!! Dots.shared.hideEventsWith(type:.mark)
        case .memoCopyAll: Dots.shared.hideEvents(with:[.memoRecord,.memoTrans,.memoTrash])
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
