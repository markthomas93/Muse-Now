
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
    
    let HourSecs = TimeInterval(60*60) // every hour
    var lastHour = TimeInterval(0)
    var lastMinute = TimeInterval(0)
    var stopTime = TimeInterval(0)
    var isOn = false
    
    /**
     Start activity, when
     1) Watch: user raises wrist
     2) Watch: return from Menu
     3) Watch+Phone: screen will reappear
     */
    func startActive() { Log("⟳ \(#function))")

        isOn = true

        func startContinue() {

            minuteTimerTick()
            anim.gotoStartupAnim()
            Closures.shared.execClosures()
            Closures.shared.addClosure(title: "Active.sendSync") {
                FilesSync.shared.sendSyncRequest() // perhaps get
                Transcribe.shared.processPendingEvents()
            }
        }

        // begin ------------------

        Record.shared.maybeRestartRecording() { isRecording in
            Motion.shared.startMotion()
            if !isRecording {
                startContinue()
            }
        }
    }
    
    /**
     Stop animation and recording, when:
     1) Watch: user lowers wrist
     2) Watch: user force touches Menu
     3) Watch+Phone: timeout of screen display
     */
    func stopActive() { Log("⟳ \(#function)")

        isOn = false

        restartTimer.invalidate()
        minuteTimer.invalidate()
        stopTime = Date().timeIntervalSince1970
        Say.shared.cancelSpeech()

        Record.shared.maybeStopRecording()
        anim.shutdownAnimation()
        Motion.shared.stopMotion()
        Location.shared.stopLocation()
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
                actions.refreshEvents(/*isSender*/false)
                // actions.doRefresh(/*isSender*/false) -- does not work for first time startup
            }
            scheduleMinuteTimer()
            isChecking = false
        }
        else {
            //Log("⟳ \(#function) duplicate")
        }
    }
}

