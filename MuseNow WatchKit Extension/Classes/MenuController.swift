//
//  MenuController.swift
//  MuseNow
//
//  Created by warren on 5/8/18.
//  Copyright © 2018 Muse. All rights reserved.
//

import WatchKit

class MenuController: WKInterfaceController {


    @IBOutlet var interfaceTable: WKInterfaceTable!
    
    var parent: TreeNode!
    var shouldPop = false

    deinit {
        NotificationCenter.default.removeObserver(self, name: ExtensionDelegate.WillResignActive, object: nil)
    }

    override func awake(withContext context: Any?) {

        super.awake(withContext: context)

        parent = context as! TreeNode
        setTitle(parent.name)

        let children = parent.children
        var rowTypes = [String]()

        for child in parent.children {
            switch child.cellType {

            case .title:            rowTypes.append("MenuTitle")
            case .titleButton:      rowTypes.append("MenuTitleButton")
            case .titleFader:       rowTypes.append("MenuTitleFader")
            case .titleMark:        rowTypes.append("MenuTitleMark")
            case .colorTitle:       rowTypes.append("MenuColorTitle")
            case .colorTitleMark:   rowTypes.append("MenuColorTitleMark")
            default:                rowTypes.append("MenuTitle")
            }
        }

        interfaceTable.setRowTypes(rowTypes) // row names. size of array is number of rows

        for index in 0 ..< children.count {

            let cell = interfaceTable.rowController(at: index) as! MenuCell
            let node = children[index]
           
            cell.setTreeNode(node)
        }
        NotificationCenter.default.addObserver(self, selector: #selector(appWillResignActive), name: ExtensionDelegate.WillResignActive, object: nil)
    }

    @objc func appWillResignActive() { Log("▤ \(#function) \(parent.name)")
         shouldPop = true
    }

//    override func didAppear() { Log("▤ \(#function) \(parent.title)")  }
//    override func willDisappear() { Log("▤ \(#function) \(parent.title)") }
//    override func didDeactivate() { Log("▤ \(#function) \(parent.title)") }

    override func willActivate() { Log("▤ \(#function) \(parent.name)")
        if  shouldPop {
            shouldPop = false
            self.pop()
        }
    }

    override func table(_ table: WKInterfaceTable, didSelectRowAt rowIndex: Int) {
        let child = parent.children[rowIndex]
        if child.children.count > 0 {
            pushController(withName: "MenuController", context: child)
        }
    }

    @IBAction func swipeRightAction(_ sender: Any) {
        self.pop()
    }
}
