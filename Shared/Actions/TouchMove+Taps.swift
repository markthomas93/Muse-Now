//  Taps.swift

import UIKit

extension TouchMove { // tapping

    /**
     - while animating, all taps pause animation, so start after first tap.
     - while paused, double tap will toggle, and triple with record.
     - since there are not quad taps, record after triple immediatly.
     */
    func tapping(_ timeStamp:TimeInterval) {

        tapWaitTimer.invalidate()

        func waitToFinish() {
             tapWaitTimer = Timer.scheduledTimer(timeInterval: tapWaitTime, target: self, selector: #selector(finishTaps), userInfo: nil, repeats: false)
        }
        // when time since last tap < 1 second, then add a tap, otherwise reset to 1
        let deltaTime = timeStamp - tapLastTime
        tapCount =  deltaTime > tapWaitTime ? 1 : tapCount + 1
        tapLastTime = timeStamp

        switch tapCount {
        case 1: beganTap1Action?(self) ; waitToFinish()
        case 2: beganTap2Action?(self) ; waitToFinish()
        case 3: beganTap3Action?(self) ; stopTaps()
        default: break
        }
    }

    func stopTaps() {

        tapWaitTimer.invalidate()
        tapLastTime = 0
        tapCount = 0
    }
    
    @objc func finishTaps() {

        Log("👆 \(#function) tapCount:\(tapCount)")
        
        switch tapCount {
        case 1: endedTap1Action?(self)
        case 2: endedTap2Action?(self)
        default: break
        }
    }
}
