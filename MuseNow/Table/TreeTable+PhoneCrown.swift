//  EventTable+PhoneCrown.swift

import UIKit

extension TreeTableVC: PhoneCrownDelegate {
    @discardableResult
    func scrollToMakeVisibleCell(_ cell:MuCell!,_ index:Int) -> Bool {
        let row = min(index+1,TreeNodes.shared.shownNodes.count-1)
        let indexPath = IndexPath(row: row, section: 0)
        let cellRect = tableView.rectForRow(at: indexPath)
        if !tableView.bounds.contains(cellRect) {
            let cellY = cellRect.origin.y
            let cellH = cellRect.size.height
            let tablY = tableView.bounds.origin.y
            let tablH = tableView.bounds.size.height

            let deltaY = cellY < tablY ? cellY - tablY  : (cellY+cellH) - (tablY+tablH)
            UIView.animate(withDuration: 0.25, animations: {
                self.tableView.contentOffset.y += deltaY
            })
            return true
        }
        return false
    }
    func scrollToNearestTouch(_ cell:TreeCell!) {

        if  let lastNode = TreeNodes.shared.shownNodes.last,
            let lastCell = lastNode.cell {

            let newPath = IndexPath(row:cell.treeNode.row,section:0)
            let newY = tableView.rectForRow(at:newPath).origin.y
            let cellY = cell.lastLocationInTable.y
            //let cellH = cell.height
            //let cellZ = cellY + cellH
            let deltaY = newY - cellY
            if deltaY < 0 {
                let lastY = tableView.rectForRow(at: IndexPath(row:lastNode.row, section:0)).origin.y
                let lastH = lastCell.height
                let lastZ = lastY+lastH

                let tablY = tableView.bounds.origin.y
                let tablH = tableView.bounds.size.height
                let tablZ = tablY+tablH
                let shift = -deltaY - ((-deltaY + lastZ) - tablZ)
                if shift > 44 {
                    //print ("*** \(Int(deltaY)):\(Int(cellZ)) \(Int(lastZ)) \(Int(tablZ)) \(Int(shift))")
                    UIView.animate(withDuration: 0.25, animations: {
                        self.tableView.contentOffset.y -= shift
                    })
                }
            }
        }
    }
        
    /**
     User force touches our double tapped on phoneCrowndouble
     */
    func phoneCrownToggle(_ isRight:Bool) { printLog ("⊛ TreeTableVC::\(#function)")
        // only toggle cell
        if isRight {
            if let touchedCell = touchedCell as? TreeTitleMarkCell,
                let treeNode = touchedCell.treeNode {

                touchedCell.mark.setMark(treeNode.toggle())
            }
        }
        else if let touchedCell = touchedCell as? TreeEditTitleCell {
            if touchedCell.textField.isFirstResponder {
                 touchedCell.textField.resignFirstResponder()
            }
            else {
                touchedCell.textField.becomeFirstResponder()
            }
        }
        else {
            touchedCell?.touchCell(CGPoint.zero)
        }
    }


    /// User touched phone crown, not needed for TreeTable
    func phoneCrownUpdate() { //printLog ("⊛ TreeTableVC::\(#function)")
    }

    /**
     User moved phone crown
     - via: PhoneCrown.[moved ended].updateDelta
     */
    func phoneCrownDeltaRow(_ deltaRow: Int,_ isRight:Bool) { // printLog ("⊛ TreeTableVC::\(#function):\(deltaRow)")

        let shownNodes = TreeNodes.shared.shownNodes

        /// slow O(n) search to find position in array
        func slowFindIndexOfCell(_ findCell:MuCell) -> Int {
            var index = 0
            for node in shownNodes {
                // found position
                if node?.cell == findCell {
                    if node?.row != index {
                        print("************* node.row:\(node?.row ?? -1) vs index:\(index)")
                    }
                    return index
                }
                index += 1
            }
            return -1
        }
        /// advance to new cell and highlight
        func highlightNextCell(_ index:Int) {
            switch index {
            case  0 ..< shownNodes.count:
                touchedCell.setHighlight(.low)  // remove highlight from old cell
                touchedCell = shownNodes[index].cell
                touchedCell?.setHighlight(.high) // add highlight to new cell
                scrollToMakeVisibleCell(touchedCell, index)
            default: break
            }
        }

        // begin here -------------------

        if touchedCell != nil {
            let index = touchedCell.treeNode?.row ?? slowFindIndexOfCell(touchedCell)
           highlightNextCell(index + deltaRow)

        }
        else if shownNodes.count > 0,
            let firstCell = shownNodes.first?.cell {

            touchedCell = firstCell
            touchedCell.setHighlight(.high)
        }
    }


}
