
import UIKit

/**
 handle UITouches with overrides for position, delta, and singleTap
 */
class TouchForce: UIViewForce {
    
    var beganPos = CGPoint(x:0, y:0)
    var movedPos = CGPoint(x:0, y:0)
    
    var beganTime = TimeInterval(0)
    var movedTime = TimeInterval(0)
    var endedTime = TimeInterval(0)
    var tapDuration = TimeInterval(0.6)
     
    // override by subclass
    func began(_ pos: CGPoint,_ time:TimeInterval){}
    func moved(_ pos: CGPoint,_ delta: CGPoint,_ time:TimeInterval){}
    func ended(_ pos: CGPoint,_ delta: CGPoint,_ time:TimeInterval){}
    func singleTap() {}

    
    //  UITouches delegate ----------------------------------------------------
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        beganTime = (event?.timestamp)!
        beganPos = (touches.first?.location(in: self))!
        began(beganPos,beganTime)
        
        isForceOn = false
        updateForce((touches.first?.force)!)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        movedTime = (event?.timestamp)!
        movedPos = (touches.first?.location(in: self))!
        let delta = CGPoint(x: movedPos.x - beganPos.x, y: movedPos.y - beganPos.y)
        moved(movedPos, delta, movedTime)
        updateForce((touches.first?.force)!)
    }
    
    // for both touchesEnded and touchesCancelled
    func touchesDone (_ touches: Set<UITouch>, _ event: UIEvent?) {
        
        endedTime = (event?.timestamp)!
        movedPos = (touches.first?.location(in: self))!
        let delta = CGPoint(x: movedPos.x - beganPos.x, y: movedPos.y - beganPos.y)
        ended(movedPos, delta, endedTime)

        let deltaTime = endedTime - beganTime
        if deltaTime < tapDuration {
            // make sure that the user was not scrolling
            let deltaPos = CGPoint(x:movedPos.x - beganPos.x, y: movedPos.y - beganPos.y)
            let distance = sqrt(deltaPos.x*deltaPos.x + deltaPos.y*deltaPos.y)
            if distance < 10 {
                singleTap()
            }
        }
        updateForce((touches.first?.force)!)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchesDone(touches, event)
    }
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchesDone(touches, event)
    }
    
}
