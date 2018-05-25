//
//  TreeTitleButtonCell.swift
//  MuseNow
//
//  Created by warren on 1/7/18.
//  Copyright © 2018 Muse. All rights reserved.
//

import WatchKit
import EventKit

class MenuTitleButton: MenuTitle {
    
    @IBOutlet var button: WKInterfaceButton!

    @IBAction func MenuTitleButtonAction() {
        Log("▤ \(#function)")
        butnAct?()
    }

    var butnAct: CallVoid?

    override func setTreeNode(_ treeNode_:TreeBase) {
        super.setTreeNode(treeNode_)
         button.setBackgroundImage(UIImage(named: "icon-button-draw.png"))
    }

}


