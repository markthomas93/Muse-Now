import UIKit
import EventKit

class MenuEdit: MenuTitle {

//    convenience required init(coder decoder: NSCoder) {
//        self.init(coder: decoder)
//    }

     override func setHighlight(_ high:Highlighting, animated:Bool = true) {
        setHighlights(high,
                     views:         [bezel],
                     borders:       [headColor,.white],
                     backgrounds:   [.black,.clear],
                     alpha:         1.0,
                     animated:      animated)
    }
}

















