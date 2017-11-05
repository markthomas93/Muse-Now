//
//  EventTable+PhoneCrown.swift

import UIKit

extension EventTableVC {
    
    /// user touched crown
    /// - via: PhoneCrown.began
    /// - via: PhoneCrown.[moved ended].updateTableRow.deltaTableRow

    func selectMiddleRow() {
        
            // prevCell is still showing
        if prevCell != nil && tableView.bounds.contains(prevCell.frame) {
            //print("??B \(#function)  event:\(prevCell.event.title)")
            return // contine from where you left off
        }
        
        // find a new cell in the middle of the frame
        if let paths = self.tableView.indexPathsForVisibleRows {
            if paths.count > 0 {
                // get middle path
                let indexPath = paths[paths.count/2]
                if let cell = tableView.cellForRow(at: indexPath) {
                    if cell is MuCell {
                        let museCell = (cell as! MuCell)
                        //print("??D \(#function) indexPath:\(indexPath) event:\(museCell.event.title)")
                        nextKoCell(museCell)
                    }
                     prevIndexPath = indexPath
                    return
                }
            }
            // while scrolling, middle path may still be offscreen, so manually update
            let height = tableView.frame.size.height
            let centerY = tableView.contentOffset.y + height/2
            //print("??EE \(#function) centerY:\(centerY)")
            
            for pathi in paths {
                if let cell = tableView.cellForRow(at: pathi) {
                    let event = (cell as! MuCell).event
                    
                    if  let event = event,
                        let posY = rowItemId[event.eventId]?.posY,
                        posY <= centerY,
                        posY + rowHeight >= centerY {

                        nextKoCell(cell as! MuCell)
                        prevIndexPath = pathi
                        return
                    }
                }
            }
        }
    }


    /// user moved crown
    /// - via: PhoneCrown.[moved ended].updateTableRow

    func deltaTableRow(_ deltaRow: Int) {
        
        anim.touchDialClockwise(deltaRow > 0)
        var nextOffset = tableView.contentOffset.y
        
        // is still selected and visible?
        if prevCell != nil &&
            prevIndexPath != nil &&
            tableView.bounds.contains(prevCell.frame) {
            
            var nextSec = (prevIndexPath?.section)!
            var nextRow = (prevIndexPath?.row)! + deltaRow
            nextOffset += CGFloat(deltaRow) * rowHeight
            
            if nextRow < 0 {
                nextSec -= 1
                nextOffset -= sectionHeight
                if nextSec < 0 {
                    return
                }
                nextRow = tableView.numberOfRows(inSection: nextSec) - 1
                if nextRow < 0 {
                    return
                }
            }
            else if nextRow >= tableView.numberOfRows(inSection: nextSec) {
                
                nextSec += 1
                nextOffset += sectionHeight
                
                if nextSec >= tableView.numberOfSections ||
                    tableView.numberOfRows(inSection: nextSec) == 0 {
                    return
                }
                nextRow = 0
            }
            let nextIndexPath = IndexPath(row: nextRow, section: nextSec)
            if let cell = tableView.cellForRow(at: nextIndexPath) {
                // printLog("⿳ \(#function) centerY:\(nextOffset)")
                prevIndexPath = tableView.indexPath(for: cell)!
                nextKoCell(cell as! MuCell)

                UIView.animate(withDuration: 0.5,
                               animations: {
                                self.tableView.contentOffset.y = nextOffset
                })
            }
        }
        else {
            selectMiddleRow()
            return
        }
    }
    

}
