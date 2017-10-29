//  CalTable+CalCell.swift

import EventKit
import UIKit

extension CalTableVC {
    
    func updateCellMarks() {
        for cell in tableView.visibleCells {
            if cell is CalCell {
                let klioCell = cell as! CalCell
                klioCell.mark.setMark(klioCell.isShowCal)
            }
        }
    }
}
