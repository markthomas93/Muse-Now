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
        if
            !blockKeyboard,
            let touchedCell = touchedCell,
            let frameVal: NSValue = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue,
            let tableView = tableView {

            blockKeyboard = true

            let keybY   = tableView.convert(frameVal.cgRectValue.origin, to: nil).y
            let cellY   = tableView.convert(touchedCell.frame.origin, to: nil).y
            let tableY  = tableView.convert(tableView.frame.origin, to: nil).y
            let scrollY = tableView.contentOffset.y + tableY

            let cellH  = touchedCell.height + 44 //?? explicit 44??
            let deltaY = cellY + cellH - keybY

            printLog ("▭ \(#function) \(cellY) + \(cellH) - \(keybY) => \(deltaY) ")
            UIView.animate(withDuration: 0.5, delay: 0.0, options:.curveEaseInOut, animations: {
                tableView.contentOffset.y = scrollY + deltaY
            }, completion:{ _ in
                let cellY = touchedCell.convert(touchedCell.frame.origin, to: nil).y
                printLog ("▭ \(#function) \(cellY)")
                self.blockKeyboard = false
            })
        }
    }

}
