//  UITouch+Force.swift

import UIKit

class UIViewForce: UIView {
    
    var forceAble = UIForceTouchCapability.unknown
    var forceNow = CGFloat(0)
    var forceOnθ = CGFloat(5)
    var forceOffθ = CGFloat(2)
    var isForceOn = false
    var forceOnTime = TimeInterval(0) // last time for turned on
    var forceOffTime = TimeInterval(0) // last time for turned off
    var recoveryTime = TimeInterval(0.25) // prevent spurious double force taps

    // override by subclass
    func forceTap(_ isForceOn:Bool){}

    func updateForce(_ force: CGFloat, _ timeStamp:TimeInterval) {
        
        if forceAble == .unknown {
            forceAble = UIApplication.shared.keyWindow?.rootViewController?.traitCollection.forceTouchCapability ?? .unknown
        }
        if forceAble == .available {
            if isForceOn {
                if force < forceOffθ {
                    isForceOn = false
                    forceOffTime = timeStamp
                    forceTap(false)
                }
            }
            else {
                let deltaTime = timeStamp - forceOffTime
                if  deltaTime > recoveryTime,
                    force > forceOnθ {

                    printLog (String(format:"👆 \(#function):%.2f",deltaTime))

                    isForceOn = true
                    forceOnTime = timeStamp
                    forceTap(true)
                }
            }
            //print (String(format:"👆 \(#function):%.2f",force))
        }
    }

}

