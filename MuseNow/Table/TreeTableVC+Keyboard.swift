//
//  TreeTableVC+KB.swift
//  MuseNow
//
//  Created by warren on 12/3/17.
//  Copyright © 2017 Muse. All rights reserved.
//
import Foundation
import UIKit

extension TreeTableVC {

    @objc func keyboardWillShow(_ notification: Notification) {

        func scrollCellAboveKeyboard(_ kbdOrigin:CGPoint) {

            if  let cell = touchedCell,
                let tableView = tableView {

                let kbdY   = kbdOrigin.y
                let cellY = cell.convert(tableView.frame.origin, to: tableView).y
                let cellH = cell.frame.size.height
                let deltaY = kbdY - cellY 

                Log ("▭ \(#function) \(cellY) + \(cellH) - \(kbdY) => \(deltaY) ")
                UIView.animate(withDuration: 0.5, delay: 0.0, options:.curveEaseInOut, animations: {
                    tableView.contentOffset.y += deltaY
                }, completion:{ _ in
                    self.blockKeyboard = false
                })
            }
        }
        // begin ---------------

//        if !blockKeyboard,
//           let kbdVal: NSValue = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue {
//            blockKeyboard = true
//
//            let kbdOrigin = kbdVal.cgRectValue.origin
//            Timer.delay(1.0) { scrollCellAboveKeyboard(kbdOrigin)}
//
//        }
    }

    @objc func keyboardWillHide(_ notification: Notification) {
        if touchedCell?.treeNode?.parent?.expanded == true {
            if  let lastSiblingNode = touchedCell?.treeNode?.parent?.children.last,
                let lastSiblingCell = lastSiblingNode.cell {

                let _ = Timer.scheduledTimer(withTimeInterval: 0.25, repeats: false, block: {_ in
                    //self.scrollToMakeVisibleCell(lastSiblingCell,lastSiblingNode.row)
                })
            }
        }
    }


}
