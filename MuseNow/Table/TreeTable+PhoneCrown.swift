//  EventTable+PhoneCrown.swift

import UIKit

extension TreeTableVC: PhoneCrownDelegate {
    @discardableResult
    func scrollToMakeVisibleCell(_ cell:MuCell!,_ index:Int) -> Bool {

        func logScroll(_ cellY:CGFloat,_ cellH:CGFloat,_ tablY:CGFloat,_ tablH:CGFloat,_ deltaY:CGFloat) {
            let scrollY = self.tableView.contentOffset.y
            let cellZ = cellY+cellH
            let tablZ = tablY+tablH
            Log (String(format:"⊛ NearestTouch H:%i S:%i C:%i_%i T:%i_%i %i⟶",
                             Int(headerY),
                             Int(scrollY),
                             Int(cellY), Int(cellZ),
                             Int(tablY), Int(tablZ),
                             Int(deltaY)))
        }



        let row = min(index,TreeNodes.shared.shownNodes.count-1)
        let indexPath = IndexPath(row: row, section: 0)
        let cellRect = tableView.rectForRow(at: indexPath)

        if !tableView.bounds.contains(cellRect) {

            let cellY = cellRect.origin.y
            let cellH = cellRect.size.height
            let tablY = tableView.bounds.origin.y
            let tablH = tableView.bounds.size.height
            let deltaY = cellY < tablY ? cellY - tablY  : (cellY+cellH) - (tablY+tablH)

         // logScroll(cellY,cellH,tablY,tablH,deltaY)

            UIView.animate(withDuration: 0.25, animations: {
                self.tableView.contentOffset.y += deltaY
            })
            return true
        }
        return false
    }
    func scrollToNearestTouch(_ cell:TreeCell!) {


        func logScroll(_ lastY:CGFloat,_ lastZ:CGFloat,_ tablY:CGFloat,_ tablZ:CGFloat,_ shift:CGFloat) {

            let newPath = IndexPath(row:cell.treeNode.row,section:0)
            let newY = tableView.rectForRow(at:newPath).origin.y
            let cellY = cell.lastLocationInTable.y
            let cellZ = cellY+cell.height
            let deltaY = newY - cellY
            let scrollY = tableView.contentOffset.y
            Log (String(format:"⊛ NearestTouch S:%i C:%i_%i L:%i_%i T:%i_%i %i⟶%i",
                             Int(scrollY),
                             Int(cellY), Int(cellZ),
                             Int(lastY), Int(lastZ),
                             Int(tablY), Int(tablZ),
                             Int(deltaY),Int(shift)))
        }
        
        if  let lastNode = TreeNodes.shared.shownNodes.last,
            let lastCell = lastNode.cell {

            let lastY = tableView.rectForRow(at: IndexPath(row:lastNode.row, section:0)).origin.y
            let lastH = lastCell.height
            let lastZ = lastY+lastH

            let tablY = tableView.bounds.origin.y
            let tablH = tableView.bounds.size.height
            let tablZ = tablY + tablH
            let shift = lastZ - tablZ

            // logScroll(lastY, lastZ, tablY, tablZ, shift)

            if shift < 0 {
                UIView.animate(withDuration: 0.25, animations: {
                    self.tableView.contentOffset.y = 0 // += shift
                })
            }
        }
    }
        
    /**
     User force touches our double tapped on phoneCrowndouble
     */
    func phoneCrownToggle(_ isRight:Bool) { Log ("⊛ TreeTableVC::\(#function)")
        // toggle mark on the right
        if  isRight,
            let touchedCell = touchedCell as? TreeTitleMarkCell,
            let treeNode = touchedCell.treeNode {
            touchedCell.mark.setMark(treeNode.toggle())
            return
        }
        // toggle field left or right
        if let touchedCell = touchedCell as? TreeEditTitleCell {
            if  touchedCell.textField.isFirstResponder {
                touchedCell.textField.resignFirstResponder()
            }
            else {
                touchedCell.textField.becomeFirstResponder()
            }
            return
        }
        // expand otherwise
        else {
            touchedCell?.touchCell(CGPoint.zero)
        }
    }


    /// User touched phone crown, not needed for TreeTable
    func phoneCrownUpdate() { //Log ("⊛ TreeTableVC::\(#function)")
    }

    /**
     User moved phone crown
     - via: PhoneCrown.[moved ended].updateDelta
     */
    func phoneCrownDeltaRow(_ deltaRow: Int,_ isRight:Bool) { // Log ("⊛ TreeTableVC::\(#function):\(deltaRow)")

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
