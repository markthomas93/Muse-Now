//  CalTable+CalCell.swift

import EventKit
import UIKit

extension CalTableVC {
    
    func updateCellMarks() {
        for cell in tableView.visibleCells {
            if cell is CalCell {
                let museCell = cell as! CalCell
                museCell.mark.setMark(museCell.isShowCal)
            }
        }
    }
}
