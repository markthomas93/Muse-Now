
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
    static let playTour = TourSet(rawValue: 1 << 0) // 1
    static let size = 1
}


class BubbleTour {

    static var shared = BubbleTour()
    var bubbles = [Bubble]()
    var tourSet = TourSet([.playTour])

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
        case .playTour: beginTour() ; Haptic.play(.start)
        case .stopTour: stopTour()  ; Haptic.play(.stop)
        default: break
        }
    }

    func beginTour() {

        tourSet.insert([.playTour])
        buildMainTour()
        buildMenuTour()

        // build linked list
        var prevBub: Bubble! = nil
        for bubble in bubbles {
            prevBub?.nextBub = bubble
            bubble.prevBub = prevBub
            prevBub = bubble
        }
        Actions.shared.doAction(.gotoFuture)
        bubbles.first?.tourBubbles()
    }
  
    func stopTour() {
        tourSet.remove([.playTour])
        //!!! didn't work PagesVC.shared.treeVC.tableView.reloadData()
        Bubbles.shared.cancelBubbles()
    }

}
