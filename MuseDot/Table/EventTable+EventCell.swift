import UIKit

extension EventTableVC {
    
    func updateCellMarks() {
        for cell in tableView.visibleCells {
            if cell is EventCell {
                let museCell = cell as! EventCell
                museCell.mark.setMark(museCell.event.mark ? 1 : 0)
            }
        }
    }

}



















