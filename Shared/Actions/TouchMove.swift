
import UIKit

public enum TouchGesture : Int { case none, swipeLeft, swipeRight }
public enum SwipeState { case swipeBegin, swipeLeft, swipeRight, swipeUp, swipeDown, cancelled, completed }

typealias CallTouchMove = ((TouchMove)->())

class TouchMove {

    var size = CGSize(width: 0, height: 0)
    var center = CGPoint(x:0,y:0)

    var isTouching      = false
    var isMoving        = false

    var touchBeganTime  = TimeInterval(0)
    var touchMovedTime  = TimeInterval(0)
    var touchEndedTime  = TimeInterval(0)
    var lastTouchTime   = TimeInterval(0)

    var touchBeganPos   = CGPoint(x:0, y:0)
    var touchMovedPos   = CGPoint(x:0, y:0)
    var touchEndedPos   = CGPoint(x:0, y:0)

    let touchMoveDist   = CGFloat(10) // must move finger 5 points before starting
    let doubleTapTime   = TimeInterval(0.5) // seconds for double tap

    var touchBegan: CallTouchMove!
    var touchMoved: CallTouchMove!

    let swipeTime       = TimeInterval(0.50) // time window for swipe
    let swipeDistance   = CGFloat(66)      // minimum distance for swipe
    var swipeLeftAction  : CallTouchMove!
    var swipeRightAction : CallTouchMove!
    var swipeUpAction    : CallTouchMove!
    var swipeDownAction  : CallTouchMove!
    var swipeState      = SwipeState.swipeBegin

    // tapping

    var tapWaitTimer = Timer()
    let tapWaitTime = TimeInterval(0.50)
    var tapLastTime = TimeInterval(0)
    var tapCount = 0

    var beganTap1Action: CallTouchMove!
    var beganTap2Action: CallTouchMove!
    var beganTap3Action: CallTouchMove!
    var endedTap1Action: CallTouchMove!
    var endedTap2Action: CallTouchMove!

    init (_ size_: CGSize) {

        size = size_
        center = CGPoint(x: size.width/2, y: size.height/2)
    }


    func testSwipe(_ pos: CGPoint) {

        let deltaX = pos.x - touchBeganPos.x
        let deltaY = pos.y - touchBeganPos.y

        let distance = sqrt(deltaX * deltaX + deltaY * deltaY)
        if !isMoving {
            isMoving = distance > touchMoveDist
            if !isMoving { return }
        }

        if distance > swipeDistance {

            // within 30˚ angle of each direction
            let isHorizontal = abs(deltaX)/2 > abs(deltaY)
            let isVertical   = abs(deltaY)/2 > abs(deltaX)

            if isHorizontal {

                switch swipeState {
                case .swipeRight:   swipeState = deltaX > 0 ? .swipeRight : .cancelled
                case .swipeLeft:    swipeState = deltaX < 0 ? .swipeLeft  : .cancelled
                case .swipeBegin:   swipeState = deltaX < 0 ? .swipeLeft  : .swipeRight
                default:            swipeState = .cancelled
                }
            }
            else if isVertical {

                switch swipeState {
                case .swipeDown:    swipeState = deltaY > 0 ? .swipeDown : .cancelled
                case .swipeUp:      swipeState = deltaY < 0 ? .swipeUp   : .cancelled
                case .swipeBegin:   swipeState = deltaY < 0 ? .swipeUp   : .swipeDown
                default:            swipeState = .cancelled
                }
            }
        }
    }

    /**
     if non-ambiguous swipe within time frame
     and there is a corresponding swipe function,
     then do that function and return true.
     */
    func finishSwipe(_ timeStamp: TimeInterval) -> Bool {

        func onAct(_ act:CallTouchMove!) -> Bool {
            if let act = act {
                act(self)
                swipeState = .completed
                return true
            }
            return false
        }

        let deltaTime = timeStamp - touchBeganTime
        if deltaTime > swipeTime {
            swipeState = .cancelled
            Log("👆\(#function) delta: \(Int(deltaTime)) state:\(swipeState)")
            return false
        }
        else {
            Log("👆\(#function) delta: \(Int(deltaTime))  state:\(swipeState)")
        }

        switch swipeState {
        case .swipeRight: return onAct(swipeRightAction)
        case .swipeLeft:  return onAct(swipeLeftAction)
        case .swipeUp:    return onAct(swipeUpAction)
        case .swipeDown:  return onAct(swipeDownAction)
        default:          return false
        }
    }

    // bottom slider for 38 is 15px, 42 is 18 px
    func began(_ pos: CGPoint, _ timestamp: TimeInterval) {

        Log("👆\(#function) pos:\(Int(pos.x)),\(Int(pos.y)) ")
        swipeState = .swipeBegin
        touchBeganTime = timestamp
        touchBeganPos = pos
        isTouching = true
        isMoving = false

        tapping(timestamp)
        touchBegan?(self)
    }

    func moved (_ pos: CGPoint, _ timestamp: TimeInterval) {

        if !isTouching {
            began(pos, timestamp)
        }
        else {
            let deltaPos = CGPoint(x:touchBeganPos.x-pos.x, y: touchBeganPos.y-pos.y)
            let deltaTime = (timestamp - lastTouchTime)
            lastTouchTime = timestamp
            let distance = sqrt(deltaPos.x*deltaPos.x + deltaPos.y*deltaPos.y)
            let speed  = distance / CGFloat(deltaTime)
            testSwipe(pos)

            Log("👆\(#function) pos:\(Int(pos.x)),\(Int(pos.y)) isMoving:\(isMoving)) dist:\(Int(distance)) speed:\(Int(speed))")

            if isMoving {

                touchMovedTime = timestamp
                touchMovedPos = pos
                touchMoved?(self)
            }
        }
    }

    /// shared by touchesEnded and touchesCancelled
    func ended (_ pos: CGPoint, _ timestamp: TimeInterval)  {

        if isTouching {

            Log("👆\(#function) pos:\(Int(pos.x)),\(Int(pos.y)) isMoving:\(isMoving))")

            let wasMoving = isMoving
            testSwipe(pos)
            if finishSwipe(timestamp) {
                stopTaps()
            }
            else if wasMoving {
                touchMoved?(self)
            }

            isMoving = false
            isTouching = false
            touchEndedPos  = pos
            touchEndedTime = timestamp
        }
    }
}
