//
//  EventTable+Scroll.swift

import UIKit

var dragEndBegin = TimeInterval(0)

extension EventTableVC {
    
    override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) { //printLog("⿳ \(#function) ")
        
        let time = getNearestTimeForOffsetY(scrollView.contentOffset.y)
        anim.scrollingGotoTime(time, duration: 0.125)
        isDragging = true
    }
    
    override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let time = getNearestTimeForOffsetY(scrollView.contentOffset.y)
        printLog("⿳ \(#function)")
        anim.scrollingGotoTime(time, duration:0.06)
        isDragging = false
    }
    
    override func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        
        isDragging = false
        
        let nextOffsetY = targetContentOffset.pointee.y
        let deltaOffsetY = nextOffsetY - prevOffsetY
  
        if deltaOffsetY != 0 {
            
            // calculate duration of animation and shorten it somewhat
            let vy = abs(Double(velocity.y))
            let p0 =  0.8 // factor to shorten predicted duration
            let p1 = -0.0190848
            let p2 =  0.30489632
            let p3 =  2.098846
            let predictedDuration = p0 * (vy * (vy * p1 + p2) + p3)
            //printLog("⿳ \(#function) velocity:\(velocity) predicted:\(predictedDuration)")
            
            let time = getNearestTimeForOffsetY(nextOffsetY)
            anim.scrollingGotoTime(time, duration: predictedDuration)
        }
    }
    
    /**
     Callback when table content offset has changed
     - via: direct user interaction with table
     - via: animating offset via PhoneCrown, or TouchDial.
     So, only update touchDial, when user is dragging table directly
     */
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if isDragging {
            let time = getNearestTimeForOffsetY(scrollView.contentOffset.y)
            anim.scrollingGotoTime(time, duration:0.25)
        }
    }
    
    func getNearestTimeForOffsetY(_ offsetY: CGFloat) -> TimeInterval {
        
        let midY = max(0,offsetY)

        // approximate middle of times and positions and search from there
        let starti = max(0,Int((offsetY / tableView.contentSize.height) * CGFloat(rowItems.count)))
        let rowItem = rowItems[starti]

        // search forward
        if rowItem.posY + rowHeight < midY {
            for i in starti ..< rowItems.count {
                if rowItems[i].posY + rowHeight > midY {
                    return rowItems[i].rowTime
                }
            }
        }
            // search backwards
        else if rowItem.posY > midY {
            for i in (0 ..< starti).reversed() {
                if rowItems[i].posY <= midY {
                    return rowItems[i].rowTime
                }
            }
        }
            // already there
        else {
            return rowItems[starti].rowTime
        }
        // this should never happen
        print("!!! \(#function) failed for offsetY:\(offsetY)")
        return Date().timeIntervalSince1970
    }

}
