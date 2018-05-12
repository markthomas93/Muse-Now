import UIKit
import EventKit

class MenuEdit: MenuTitle {

    convenience required init(coder decoder: NSCoder) {
        self.init(coder: decoder)
    }

    convenience init(_ treeNode_: TreeNode!) {

        self.init()
        treeNode = treeNode_
        let vc = TreeNodes.shared.vc as! UIViewController
        let width = vc.view.frame.size.width
        frame.size = CGSize(width:width, height:height)
        buildViews(width)
    }
    override func setHighlight(_ high:Highlighting, animated:Bool = true) {
        setHighlights(high,
                     views:         [bezel],
                     borders:       [headColor,.white],
                     backgrounds:   [.black,.clear],
                     alpha:         1.0,
                     animated:      animated)
    }
}

















