
import Foundation
import UIKit

enum BubContent { case  text, picture, video }

class BubbleTour {

    var bubbles = [Bubble]()
    var nextBub: Bubble!
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
            default: continue
            }
        }
        return bubItems
    }

    func beginTour() {

        //buildEventsTour()
        buildDialogTour()

        // build linked list
        var prevBub:Bubble! = nil
        for bubble in bubbles {
            prevBub?.nextBub = bubble
            prevBub = bubble
        }
        Actions.shared.doAction(.gotoFuture)
        bubbles.first?.tourBubbles()
    }

}
