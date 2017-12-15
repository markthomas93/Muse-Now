//  WatchCon+Crown.swift

import WatchKit

class Crown: NSObject, WKCrownDelegate {
    
    static let shared = Crown()
    let anim = Anim.shared
    let dots = Dots.shared
    var crown : WKCrownSequencer!
    var crownSpeed  = Double(0)
    var crownPrev   = Double(0)
    var rotatePrev  = Double(0)
    var crownStartTime = TimeInterval(0)
    var crownStopTime  = TimeInterval(0)
    
    func updateCrown() {
        
        crown = WKExtension.shared().rootInterfaceController!.crownSequencer
        crown.delegate = self
        crown.focus()
    }
    func crownDidRotate(_ crownSequencer: WKCrownSequencer?, rotationalDelta: Double) {
        
        crownStartTime = Date().timeIntervalSince1970
        let elapsedTime = crownStopTime - crownStartTime
        if elapsedTime > 2 {
            crownPrev = 0
            rotatePrev = 0
            anim.touchDialDown()
        }
        
        let factor = Double(5)
        let rotateNext = rotationalDelta * factor
        let crownNext  = crownPrev + rotateNext
        // crownSpeed = (crownSequencer?.rotationsPerSecond)!
       // Log (String(format:"⊛ elapse: %.1f  crown: %.3f -> %.3f  rotate: %.3f -> %.3f", elapsedTime, crownPrev, crownNext, rotatePrev, rotateNext))
        if floor(crownPrev) != floor(crownNext) {
            
            let delta = Float(crownPrev < crownNext ? 1 : -1)
            let inFuture = anim.animNow.rawValue > 0
            anim.animNow = inFuture ? .futrPause : .pastPause
            dots.crownNextEvent(delta, inFuture) // dots.crownNextEventOrHour(delta, inFuture)
        }
        crownPrev = crownNext
        rotatePrev = rotateNext
    }
    
    func crownDidBecomeIdle(_ crownSequencer: WKCrownSequencer?) {
        crownStopTime = Date().timeIntervalSince1970
    }

}
