//
//  TreeInfo.swift
//  MuseNow
//
//  Created by warren on 12/15/17.
//  Copyright © 2017 Muse. All rights reserved.
//

import Foundation
import UIKit

class TreeInfo {
    
    var text = ""
    var height = CGFloat(0)
    var tableVC: UITableViewController!
    init (_ parent:TreeNode!,_ text_:String,height height_:CGFloat,_ tableVC_:UITableViewController) {
        text = text_
        height = height_ 
        tableVC = tableVC_

        parent.treeInfo = self
        parent.showInfo = .newInfo
        if let cell = parent.cell {
            cell.updateInfo(tableVC.view.frame.size.width)
        }
    }
    func showInfoCell(from: UIView,in inView: UIView) {
        let _ = BubbleText(text, from:from, in:inView, on:tableVC.tableView)
    }
}
