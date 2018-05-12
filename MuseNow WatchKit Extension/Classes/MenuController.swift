//
//  MenuController.swift
//  MuseNow
//
//  Created by warren on 5/8/18.
//  Copyright © 2018 Muse. All rights reserved.
//

import WatchKit

class MenuController: WKInterfaceController {

    @IBAction func panAction(_ sender: Any) {
    }
    @IBOutlet var interfaceTable: WKInterfaceTable!
    
    var parent: TreeNode!
    
    override func awake(withContext context: Any?) {

        super.awake(withContext: context)
        
        parent = context as! TreeNode
        
        let children = parent.children
        var rowTypes = [String]()

        for node in parent.children {
            switch node.nodeType {

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
        //interfaceTable.setNumberOfRows(children.count, withRowType:"TreeTitleCell")

        for index in 0 ..< children.count {

            let cell = interfaceTable.rowController(at: index) as! MenuCell
            let node = children[index]
            cell.setTreeNode(node)
        }
    }

    override func table(_ table: WKInterfaceTable, didSelectRowAt rowIndex: Int) {
        let child = parent.children[rowIndex]
        if child.children.count > 0 {
            pushController(withName: "MenuController", context: child)
        }
    }
}
