import UIKit

extension EventTableVC {
    
    func updateCellMarks() {
        for cell in tableView.visibleCells {
            if cell is EventCell {
                let klioCell = cell as! EventCell
                klioCell.mark.setMark(klioCell.event.mark)
            }
        }
    }

}



















