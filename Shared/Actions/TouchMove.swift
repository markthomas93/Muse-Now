
import UIKit

class TouchMove {

    var size = CGSize(width: 0, height: 0)
    var center = CGPoint(x:0,y:0)

    var isTouching      = false
    var isMoving        = false
    var touchBeganTime  = TimeInterval(0)
    var touchMoveTime   = TimeInterval(0)
    var touchEndedTime  = TimeInterval(0)
    var touchBeganPos   = CGPoint(x:0, y:0)
    var touchMovePos    = CGPoint(x:0, y:0)

    let touchMoveDist   = CGFloat(10) // must move finger 5 points before starting
    let doubleTapTime   = TimeInterval(0.5) // seconds for double tap

    init (_ size_: CGSize) {

        size = size_
        center = CGPoint(x: size.width/2, y: size.height/2)
    }

    // bottom slider for 38 is 15px, 42 is 18 px
    func began(_ pos: CGPoint, _ timestamp: TimeInterval) {

        touchBeganTime = timestamp
        touchBeganPos = pos
        isTouching = true
        isMoving = false
        doBegin(pos, timestamp)
    }

    func moved (_ pos: CGPoint, _ timestamp: TimeInterval) {

        if !isTouching {
            began(pos, timestamp)
        }
        else {
            if !isMoving {
                let deltaPos = CGPoint(x:touchBeganPos.x-pos.x, y: touchBeganPos.y-pos.y)
                let distance = sqrt(deltaPos.x*deltaPos.x + deltaPos.y*deltaPos.y)
                //print("touches !moved pos:\(pos) distance:\(distance)")
                isMoving = (distance > touchMoveDist)
            }
            if isMoving {

                if touchMoveTime == 0 {
                    touchMoveTime = touchBeganTime
                }
                touchMoveTime = timestamp
                touchMovePos = pos
                doMove(pos,timestamp)
            }
        }
    }

    /// shared by touchesEnded and touchesCancelled
    func ended (_ pos: CGPoint, _ timestamp: TimeInterval)  {

        isTouching = false
        touchEndedTime = timestamp

        if isMoving {
            isMoving = false
            doMove(pos,timestamp)
        }
    }

    func doBegin(_ pos: CGPoint, _ timeStamp: TimeInterval) {
         Actions.shared.dialColor(Float(pos.x/size.width), isSender:true)
    }
    func doMove(_ pos: CGPoint, _ timestamp: TimeInterval) {
         Actions.shared.dialColor(Float(pos.x/size.width), isSender:true)
    }
}
