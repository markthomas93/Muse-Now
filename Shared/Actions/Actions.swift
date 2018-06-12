import UIKit
import WatchKit
import EventKit
import SpriteKit


public enum DoAction : String, Codable { case

    unknown,

    // refresh view
    refresh = "refresh",

    // update routine settings
    updateRoutine = "updateRoutine",
    updateEvent = "updateEvent",

    // page
    gotoPageMain = "gotoPageMain",
    gotoPageMenu = "gotoPageMenu",
    gotoPageOnboard = "gotoPageOnboard",

    // event dial
    gotoEvent = "gotoEvent",
    gotoFuture = "gotoFuture",
    gotoRecordOn = "gotoRecordOn",

    // say
    sayMemo = "sayMemo",
    sayTime = "sayTime",
    sayEvent = "sayEvent",
    speakLow = "speakLow",
    speakMedium = "speakMedium",
    speakHigh = "speakHigh",

    // hear
    hearEarbuds = "hearEarbuds",
    hearSpeaker = "hearSpeaker",

    // tour
    tourAll = "tourAll",
    tourMain = "tourMain",
    tourDetail = "tourDetail",
    tourMenu = "tourMenu",
    tourIntro = "tourIntro",
    tourStop = "tourStop",

    // show
    showCalendar = "showCalendar",
    showReminder = "showReminder",
    showRoutine = "showRoutine",
    showRoutList = "showRoutList",
    showMemo = "showMemo",

    // memoe
    memoWhere = "memoWhere",
    memoNod2Rec = "memoNod2Rec",
    memoCopyAll = "memoCopyAll",
    memoClearAll = "memoClearAll",

    // dial
    dialColor = "dialColor",

    // debug
    debug  = "debug"
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
    func refreshEvents(_ isSender:Bool) {  Log("⌘ \(#function) begin")

        MuEvents.shared.updateEvents() { Log("⌘ MuEvents done")

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

            Log("⌘ \(#function) done")

        }
    }

    func doRefresh(_ isSender:Bool) {

        Closures.shared.addClosure(title: "Actions.refresh") {
            Say.shared.cancelSpeech()
            self.refreshEvents(isSender)
        }
    }
    
    private func doUpdateRoutine() {

        Closures.shared.addClosure(title: "Actions.updateRoutine") {
            Routine.shared.archiveRoutine() {}
        }
    }

    private func doUpdateEvent(_ event:MuEvent,_ isSender:Bool) {
        
        Say.shared.cancelSpeech()
        if !MuEvents.shared.updateEvent(event) {
             MuEvents.shared.addEvent(event)
        }
        tableDelegate?.updateTable(MuEvents.shared.events)
        scene.updateSceneFinish()
        if [.memoRecord,.memoTrans,.memoTrash].contains(event.type) {
            Memos.shared.archiveMemos {}
        }
        if !isSender {
            doAction(.gotoEvent, event)
        }
    }
    
    func doTourAction(_ act:DoAction) {
        #if os(iOS)
        Tour.shared.doTourAction(act)
        #endif
    }

    func doDialColor(_ value:Float) {
        Settings.shared.dialColor = value
        scene?.uFade?.floatValue = value
    }
    //-----------------------------------------

    /** Dispatch commands to Show, Say, Hear, Dots, Anim */
    func doAction(_ act: DoAction, value: Float = 0, _ event:MuEvent! = nil, _ index:Int = 0, isSender:Bool = false) {

        Log("⌘ doAction .\(act) \(event?.title ?? "")")

        func syncMessage(isCache:Bool) {
            if isSender {
                var msg: [String : Any] = ["Action" : act, "value": value]
                if let event = event {
                    do {
                        let data = try JSONEncoder().encode(event)
                        msg["event"] = data
                    }
                    catch {
                        print("!!! \(#function) \(error)")
                    }
                }
                if isCache  { Session.shared.cacheMsg(msg) }
                else        { Session.shared.sendMsg(msg) }
            }
        }

        switch act {

        case .dialColor:        doDialColor(value)  ; syncMessage(isCache:true)

        case .refresh:          doRefresh(isSender)  ; syncMessage(isCache:false)

        case .updateRoutine:    doUpdateRoutine()  ; syncMessage(isCache:true)

        case .updateEvent:      doUpdateEvent(event, isSender)  ; syncMessage(isCache:true)

        case .showCalendar,
             .showReminder,
             .showMemo,
             .showRoutine,
             .showRoutList:     Show.shared.doShowAction(act, value) ; syncMessage(isCache:true)

        case .tourAll,
             .tourMain,
             .tourMenu,
             .tourDetail,
             .tourIntro,
             .tourStop:         doTourAction(act) // nond

        case .sayMemo,
             .sayTime,
             .sayEvent,
             .speakLow,
             .speakMedium,
             .speakHigh:        Say.shared.doSayAction(act, value) ; syncMessage(isCache:true)
            
        case  .hearEarbuds,
              .hearSpeaker:     Hear.shared.doHearAction(act, value)  ; syncMessage(isCache:true)

        case .gotoEvent,
             .gotoRecordOn,
             .gotoFuture:       Anim.shared.doAnimAction(act, value, event)  ; syncMessage(isCache:false)


        case .memoCopyAll,
             .memoClearAll,
             .memoWhere,
             .memoNod2Rec:      Memos.shared.doMemoAction(act, value, isSender) ; syncMessage(isCache:true)

        case .debug:            scene.debugUpdate = value > 0 ? true : false

        case .unknown: break

        case .gotoPageMain,
             .gotoPageMenu,
             .gotoPageOnboard: break
        }
    }

}
