
import UIKit


class TouchDial: TouchMove {
    
    let anim = Anim.shared
    let dots = Dots.shared
    var table: MuseTableDelegate!

    var lastPanT = TimeInterval(0)
    var lastPan˚ = Double(-720)
    var wasFuture = true

    convenience init(_ size_: CGSize, _ delegate_: MuseTableDelegate!) {

        self.init(size_)
        table = delegate_

        touchBegan = { touchMove in
            self.anim.touchDialDown()
        }

        touchMoved = { touchMove in
            let pos = touchMove.touchMovedPos
            let inv = CGPoint(x: pos.x/2, y: (self.size.width - pos.y)/2)
            self.touchDialPan(inv, touchMove.touchMovedTime)
        }

        var wasPausing = false

        beganTap1Action = {  touchMove in //Log("👆 touchBeganTap1")

            wasPausing = self.anim.pauseAnimation()
        }
        endedTap1Action = {  touchMove in Log("👆 touchEndedTap1")
            if wasPausing { // if was paused then unpause
                self.anim.resumeScan()
            }
        }
        endedTap2Action = {  touchMove in //Log("👆 touchEndedTap2")
            Actions.shared.doToggleMark() // toggle mark
        }
        beganTap3Action = {  touchMove in //Log("👆 touchBeganTap3")
            Record.shared.toggleRecordAction()
        }

    }

    func pointDegree(_ pos: CGPoint, _ center: CGPoint) -> Double {
        
        let delta = CGPoint(x: pos.x - center.x/2, y: pos.y - center.y/2)
        let angle = atan2(Double(delta.x),Double(delta.y)) + 3 * Double.pi
        let angle2 = angle.truncatingRemainder(dividingBy: 2*Double.pi)
        let degree = angle2 * 360.0 / (2*Double.pi)
        return degree
    }

    /// - via: TouchDial.(moved ended)

    func touchDialPan(_ pos: CGPoint,_ timestamp: TimeInterval) {
        
        let next˚ = pointDegree(pos, center)
        if next˚ == lastPan˚ {
            return
        }
        dots.updateViaPan(next˚)  // anim.clockise is updated
        anim.userDotAction()
        
        // calc whether fast or slow, needed for Watch version 1
        var delta˚ = next˚-lastPan˚
        let isNewDay = abs(delta˚) > 180
        if  isNewDay { delta˚ +=  next˚ < lastPan˚ ? 360 : -360 }
        var deltaT = timestamp - lastPanT
        if abs(deltaT) < 0.01 { deltaT = deltaT < 0 ? -0.1 : 0.1 }

        let speed = trunc(delta˚/deltaT)
        let isClockwise = speed >= 0
        let isSlow = abs(speed) < 360
        let isFuture = anim.animNow.rawValue > 0
        let flipFuture = isFuture != wasFuture

        //Log("👆 \(#function) degree:\(trunc(next˚)) isSlow:\(isSlow)")

        // save for comparison next time
        lastPanT = timestamp
        lastPan˚ = next˚
        wasFuture = isFuture

        // slow twiddle around dial
        if Int(dots.dotPrev) != Int(dots.dotNow) {

            dots.updateFeedback(nil, isClockwise, isFuture, isSlow, isNewDay, flipFuture)
        }

        #if os(iOS)
            
            let remain˚ = lastPan˚ - trunc(lastPan˚/15)*15
            let remainT = remain˚ * 3600/15 // seconds
            let (event,delta) = dots.getNearestEvent(remainT)
            //print ("˚ \(Int(dots.dotNow)): \( event != nil ? event!.title : "") \(delta) ˚\(trunc(lastPan˚*100)/100)")
            if let event = event {
                table.scrollDialEvent(event,delta)
            }
        #endif
    }
}
