
import Foundation
import UIKit

enum BubContent { case  text, picture, video }

extension UIWindow {
    open override func motionEnded(_ motion: UIEventSubtype, with event: UIEvent?) {
        super.motionEnded(motion, with: event)
        if motion == .motionShake {
            Actions.shared.doAction(.stopTour)
        }
    }
}
struct TourSet: OptionSet {
    let rawValue: Int
    static let tourOnboard  = TourSet(rawValue: 1 << 0) // 1
    static let tourMain     = TourSet(rawValue: 2 << 0) // 2
    static let tourMenu     = TourSet(rawValue: 3 << 0) // 4
    static let size = 3
}

class BubbleTour {

    static var shared = BubbleTour()

    var bubbles = [Bubble]()
    var bubbleNow: Bubble!

    var tourSet = TourSet([.tourOnboard,.tourMain,.tourMenu])

    var mainView: UIView! // full screen view in which to place subview

    func bubsFrom(anys:[Any]) -> [BubbleItem] {

        var bubItems = [BubbleItem]()
        var bubItem: BubbleItem!
        for any in anys {
            switch any {
            case let any as String:     bubItem = BubbleItem(any,4.0) ; bubItems.append(bubItem)
            case let any as Int:        bubItem?.duration = TimeInterval(any) // modify last item
            case let any as Double:     bubItem?.duration = TimeInterval(any) // modify last item
            case let any as Float:      bubItem?.duration = TimeInterval(any) // modify last item
            case let any as CallWait:   bubItem?.callWait = any // // modify last item
            case let any as CallVoid:   bubItem?.callWait = { _, finish in any() ; finish()}
            default: continue
            }
        }
        return bubItems
    }

    func doTourAction(_ act:DoAction) {

        switch act {
        case .tourMain:     beginTourSet([.tourMain])    ; Haptic.play(.start)
        case .tourMenu:     beginTourSet([.tourMenu])    ; Haptic.play(.start)
        case .tourOnboard:  beginTourSet([.tourOnboard]) ; Haptic.play(.start)
        case .stopTour:     stopTour()                   ; Haptic.play(.stop)
        default: break
        }
    }

    func beginTourSet(_ tourSet_:TourSet) {
        return  //???//
        tourSet = tourSet_
        if tourSet.contains([.tourMain]) { buildMainTour() }
        if tourSet.contains([.tourMenu]) { buildMenuTour() }

        // build linked list
        var prevBubble: Bubble! = nil
        for bubble in bubbles {
            prevBubble?.nextBubble = bubble
            bubble.prevBubble = prevBubble
            prevBubble = bubble
        }
        Actions.shared.doAction(.gotoFuture)
        bubbles.first?.tourBubbles()
    }
  
    func stopTour() {
        BubblesPlaying.shared.cancelBubbles()
        tourSet = []
        // clear out memory?
        for bubble in bubbles {
            bubble.prevBubble = nil
        }
        bubbles.removeAll()
        TouchScreen.shared.endRedirecting()
    }

}
