//  Taps.swift

import UIKit

class Taps {
    
    static let shared = Taps()
    
    //var scene: Scene!
    let anim = Anim.shared
    
    var waitTimer = Timer()
    let waitTime = TimeInterval(0.50)
    var lastTime = TimeInterval(0)
    var tapCount = 0
    var wasPausing = false

    /**
     - while animating, all taps pause animation, so start after first tap.
     - while paused, double tap will toggle, and triple with record.
     - since there are not quad taps, record after triple immediatly.
     */
    func tapping(_ timeStamp:TimeInterval) {

        waitTimer.invalidate()

        // when time since last tap < 1 second, then add a tap, otherwise reset to 1
        //let deltaTime = lastTime == 0 ? 0 : timeStamp - lastTime
        tapCount = lastTime == 0 ? 1 : tapCount + 1
        lastTime = timeStamp
        //Log("👆 \(#function) tapCount:\(tapCount) deltaTime:\(deltaTime)")

        switch tapCount {
        case 1: wasPausing = anim.pauseAnimation()
        case 3: Record.shared.toggleRecordAction() ; doneTapping() ; return
        default: break
        }
        waitTimer = Timer.scheduledTimer(timeInterval: waitTime, target: self, selector: #selector(finishTaps), userInfo: nil, repeats: false)
    }

    func doneTapping() {
        tapCount = 0
        lastTime = 0
        wasPausing = false
    }

    @objc func finishTaps() {// Log("👆 \(#function) tapCount:\(tapCount)")
        
        switch tapCount {
        case 1: if wasPausing {anim.resumeScan()}  // if was paused then unpause
        case 2: Actions.shared.doToggleMark() // toggle mark
        case 3: break
        default: break
        }
        doneTapping() // last tap gets immediate response
    }
}
