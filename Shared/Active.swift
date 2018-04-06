
import SceneKit
import SpriteKit
import UIKit
import WatchKit
import Foundation


class Active {
    
    static let shared = Active()
    static let lifeTime = Date().timeIntervalSince1970 // seconds since start of program, for debugging
    
    let actions = Actions.shared
    let anim = Anim.shared
    var scene: Scene!
    
    var minuteTimer = Timer()   // 1 minute timer to update time's position
    var restartTimer = Timer()  // delay update to handle menu options
    var noddingTimer = Timer() // deactivate/activate during throttle gesture
    
    let HourSecs = TimeInterval(60*60) // every hour
    var lastHour = TimeInterval(0)
    var lastMinute = TimeInterval(0)
    var stopTime = TimeInterval(0)
    
    /**
     Start activity, when
     1) Watch: user raises wrist
     2) Watch: return from Menu
     3) Watch+Phone: screen will reappear
     */
    func startActive() { Log("⟳ \(#function) recording:\(Record.shared.isRecording())")

        func beginActive() {
            minuteTimerTick()
            anim.addClosure(title: "send sync", { self.sendSyncRequest()})
        }

        func spinUp() {
            Motion.shared.startMotion()
            Record.shared.activateAudio()
            // sometimes, immediately after deactivate, a spurious willActivate is called, so ignore
            let thisTime =  Date().timeIntervalSince1970
            let deltaTime = thisTime - stopTime

            if deltaTime < 120 {
                // delay restart to handle menuOptions
                restartTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false, block: {_ in
                    beginActive()
                })
            }
            else {
                beginActive()
            }
        }
        
        // begin
        if Record.shared.isRecording() {
            noddingTimer.invalidate()
        }
        else {
            spinUp()
            anim.gotoStartupAnim()
        }
    }
    
    /**
     Stop animation and recording, when:
     1) Watch: user lowers wrist
     2) Watch: user force touches Menu
     3) Watch+Phone: timeout of screen display
     */
    func stopActive() { Log("⟳ \(#function) recording:\(Record.shared.isRecording())")
        
        func windDown() {
            restartTimer.invalidate()
            minuteTimer.invalidate()
            Say.shared.cancelSpeech() ;  Log("🗣 \(#function)")
            stopTime = Date().timeIntervalSince1970
            anim.shutdownAnimation()
            Motion.shared.stopMotion()
            Location.shared.stopLocation()
        }
        // if lower wrist and not raise withing 1 second, then recording was a false positive, so cancel recording
        if Record.shared.isRecording() {
            noddingTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false, block: {_ in
                Record.shared.cancelRecording()
                windDown()
            })
        }
        else {
            windDown()
        }
    }
    
    
    func sendSyncRequest() {
        
        Settings.shared.sendSyncFile()
        MuEvents.shared.marks.sendSyncFile()
        MuEvents.shared.memos.sendSyncFile()
        Cals.shared.sendSyncFile()
        Routine.shared.sendSyncFile()
    }
    
    /**
     Pause animation when user gestures
     - via watchCon.menu*Action
     - via motion.bang()
     - via actionDelegate
     */
    func startMenuTime() { //Log("⟳ \(#function)")
        restartTimer.invalidate()
        anim.animNow = .futrPause
        anim.actionTime = Date().timeIntervalSince1970
    }
    
    /**
     for .time event, update title every minute
     - via cellTimerTick
     */
    func scheduleMinuteTimer() { //Log("⟳ \(#function)")
        
        let comps = (Calendar.current as NSCalendar).components([.second], from: Date())
        var nextMinute = TimeInterval(60 - comps.second!) + 0.02 // add a little over one frames at 60 fps
        // for first time startup
        if nextMinute < 10 {
            nextMinute += 60
        }
        minuteTimer = Timer.scheduledTimer(timeInterval: nextMinute, target:self, selector: #selector(self.minuteTimerTick), userInfo: nil, repeats: false)
    }
    
    
    /** called every minute, will update timeEvent's position in events and refresh hours
     */
    var isChecking = false // make atomic
    
    @objc func minuteTimerTick() {
        
        minuteTimer.invalidate()
        
        if !isChecking {
            isChecking = true
            
            let timeNow = Date().timeIntervalSince1970
            let thisMinute = trunc(timeNow/60)*60
            let thisHour = trunc(timeNow/HourSecs)*HourSecs
            
            if lastMinute != thisMinute { // Log("⟳ \(#function) lastMin:\(lastMinute) thisMin:\(thisMinute)")
                lastMinute = thisMinute
                actions.doMinuteTimerTick()
            }
            if lastHour != thisHour {  // Log("⟳ \(#function) lastHour:\(lastHour) thisHour:\(thisHour)")
                lastHour = thisHour
                actions.doRefresh(/*isSender*/false) // will set isPaused = true, after update
            }
            scheduleMinuteTimer()
            isChecking = false
        }
        else {
            Log("⟳ \(#function) duplicate")
        }
    }
}

