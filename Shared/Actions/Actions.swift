import UIKit
import WatchKit
import EventKit
import SpriteKit


public enum DoAction : Int,Codable { case

    unknown,

    // refresh view
    refresh,

    // page
    gotoPageMain, gotoPageMenu, gotoPageOnboard,

    // event dial
    gotoEvent, gotoFuture, gotoRecordOn,

    // say
    saySpeech, sayMemo, sayTime, sayEvent,
    speakLow, speakMedium, speakHigh,

    // hear
    hearEarbuds, hearSpeaker,

    // tour
    tourAll, tourMain, tourDetail, tourMenu, tourIntro, tourStop,

    // show
    showCalendar,  showReminder, showRoutine, showRoutList, showMemo,

    // memoe
    memoWhere, memoNod2Rec, memoCopyAll, memoClearAll,

    // dial
    dialColor,

    // debug
    debug
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
    var suggestions   = [String]()

    func dialColor(_ fade:Float, isSender: Bool)  {
        
        scene?.uFade?.floatValue = fade
        
        if isSender {

            Session.shared.sendMsg( ["class" : "Actions", "dialColor" : fade])
            Settings.shared.dialColor = fade
        }
    }

    func doSetTitle(_ title_: String) {
        #if os(watchOS)
            WKExtension.shared().rootInterfaceController?.setTitle(title_)
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
    func refreshEvents(_ isSender:Bool) {

        TreeNodes.shared.unarchiveTree() {

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
    }

    func doRefresh(_ isSender:Bool) {

        Closures.shared.addClosure(title: "Actions.reset") {
            Say.shared.cancelSpeech()
            self.refreshEvents(isSender)
        }
    }

    func doUpdateEvent(_ event:MuEvent, isSender: Bool) {
        
        Say.shared.cancelSpeech()
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
    

    //-----------------------------------------
 
    /**
     Dispatch commands to Show, Say, Hear, Dots, Anim
     - via: Actions.[doUpdateEvent, doToggleMark]
     - via: Session.parseMsg["Action":]
     - via: EventCell.touchMark
     */
    func doAction(_ act: DoAction, value: Float = 0, _ event:MuEvent! = nil, _ index:Int = 0, isSender:Bool = false) {
        
        Log("⌘ \(#function):\(act) event:\(event?.title ?? "nil")")
        
        switch act {
            
        case .showCalendar, .showReminder, .showMemo, .showRoutine, .showRoutList:

            Show.shared.doShowAction(act, value, isSender)

        case .tourAll, .tourMain, .tourMenu, .tourDetail, .tourIntro, .tourStop:
            #if os(iOS)
                Tour.shared.doTourAction(act)
            #endif
        // speech to text volume
        case .sayMemo, .sayTime, .sayEvent, .speakLow, .speakMedium, .speakHigh:

            Say.shared.doSayAction(act, value, isSender)

        case  .hearEarbuds, .hearSpeaker:

            Hear.shared.doHearAction(act, value, isSender)

        case .gotoEvent,
             .gotoRecordOn,
             .gotoFuture:

            Anim.shared.doAnimAction(act,value, event, isSender)
            
        case .memoCopyAll, .memoClearAll, .memoWhere, .memoNod2Rec:

            Memos.shared.doMemoAction(act, value, isSender)
            
        case .refresh: doRefresh(isSender)
            
        case .debug: scene.debugUpdate = value > 0 ? true : false
    
        default: break
        }
    }
      

}
