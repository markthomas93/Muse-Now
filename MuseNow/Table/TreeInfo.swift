//
//  TreeInfo.swift
//  MuseNow
//
//  Created by warren on 12/15/17.
//  Copyright © 2017 Muse. All rights reserved.

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
    func showInfoCell(from childView: UIView!, in parentView: UIView!, done: ((Bool)->())? = nil ) {

        let size =  CGSize(width:160,height:120) // CGSize(width:160,height:120)

        let fname = "X_dial_320x240"
        let panelView = MainVC.shared!.panel
        let family:[UIView] = [tableVC.tableView, parentView, childView]
        let covers:[UIView] = [panelView,tableVC.tableView]


        //let poi =

        for _ in 0...5 {
            //let _ = BubbleVideo(TourPoi("yo",.right,.settings,.video,size,family,covers,fname:fname)).go() { result in done?(result) }
            //let _ = BubbleVideo(TourPoi("yo",.above,.settings,.video,size,family,covers,fname:fname)).go() { result in done?(result) }
            let _ = BubbleVideo(TourPoi("yo",.below,.settings,.video,size,family,covers,fname:fname)).go() { result in done?(result) }
        }


    }
}
