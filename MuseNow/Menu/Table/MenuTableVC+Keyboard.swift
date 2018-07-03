//
//  MenuTableVC+KB.swift
// muse •
//
//  Created by warren on 12/3/17.
//  Copyright © 2017 Muse. All rights reserved.

import Foundation
import UIKit

extension MenuTableVC {

    @objc func keyboardWillShow(_ notification: Notification) {

        func scrollCellAboveKeyboard(_ kbdOrigin:CGPoint) {

            if  let mainView = MainVC.shared!.view,
                let cell = touchedCell,
                let tableView = tableView {

                let kbdY   = kbdOrigin.y
                let cellY  = cell.convert(mainView.frame.origin, to: mainView).y
                let cellH  = cell.frame.size.height
                let deltaY = kbdY - cellY - cellH

                Log ("▭ \(#function) \(cellY) + \(cellH) - \(kbdY) => \(deltaY) ")
                UIView.animate(withDuration: 0.5, delay: 0.0, options:.curveEaseInOut, animations: {
                    tableView.contentOffset.y -= deltaY
                }, completion:{ _ in
                    self.blockKeyboard = false
                })
            }
        }
        // begin ---------------

        if !blockKeyboard,
           let kbdVal: NSValue = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue {

            blockKeyboard = true

            let kbdOrigin = kbdVal.cgRectValue.origin
            Timer.delay(0.25) { scrollCellAboveKeyboard(kbdOrigin)}

        }
    }

    @objc func keyboardWillHide(_ notification: Notification) {
        if touchedCell?.treeNode?.parent?.expanded == true {
            if  let lastSiblingNode = touchedCell?.treeNode?.parent?.children.last,
                let lastSiblingCell = lastSiblingNode.cell {
                Timer.delay(0.25) {
                    self.scrollToMakeVisibleCell(lastSiblingCell,lastSiblingNode.row)
                }
            }
        }
    }


}
