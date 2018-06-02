
import UIKit


/// marshal fourceTap to select item on dial
/// - init from EventVC.viewDidLoad
/// - via: TouchForce.(began moved ended) -> touchDial.(began moved ended)
/// - via: TouchForce.forceTap -> doToggleMark()
class TouchDialForce: TouchForce {
    
    var touchDial : TouchDial!
    // override by subclass
    override func began(_ pos: CGPoint,                 _ time: TimeInterval) { touchDial.began(pos, time) }
    override func moved(_ pos: CGPoint,_ delta: CGPoint,_ time: TimeInterval) { touchDial.moved(pos, time) }
    override func ended(_ pos: CGPoint,_ delta: CGPoint,_ time: TimeInterval) { touchDial.ended(pos, time) }
    override func forceTap(_ isForceOn: Bool) { if isForceOn { Marks.shared.doToggleMark()}}
}


