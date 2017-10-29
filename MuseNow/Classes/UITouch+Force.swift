//  UITouch+Force.swift

import UIKit

class UIViewForce: UIView {
    
    var forceAble = UIForceTouchCapability.unknown
    var forceNow = CGFloat(0)
    var forceOnθ = CGFloat(5)
    var forceOffθ = CGFloat(2)
    var isForceOn = false
    
    // override by subclass
    func forceTap(_ isForceOn:Bool){}

    func updateForce(_ force: CGFloat) {
        
        if forceAble == .unknown {
            forceAble = UIApplication.shared.keyWindow?.rootViewController?.traitCollection.forceTouchCapability ?? .unknown
        }
        if forceAble == .available {
            if isForceOn {
                if force < forceOffθ {
                    isForceOn = false
                    forceTap(isForceOn)
                }
            }
            else {
                if force > forceOnθ {
                    isForceOn = true
                    forceTap(isForceOn)
                }
            }
            //print (String(format:"👆 \(#function):%.2f",force))
        }
    }

}

