
import Foundation
import UIKit

enum BubContent { case  text, picture, video }

class BubbleTour {

    var bubbles = [BubbleItem]()
    var nextBub: BubbleItem!

    func beginTour() {

        buildEventsTour()
        buildSettingsTour()

        // build linked list
        var prevBub:BubbleItem! = nil
        for bubi in bubbles {
            prevBub?.nextBub = bubi
            bubi.prevBub = prevBub
            prevBub = bubi
        }

        // animate dial to show whole week
        Anim.shared.animNow = .futrWheel
        Anim.shared.userDotAction()

        bubbles.first?.tourBubbles()
    }

}
