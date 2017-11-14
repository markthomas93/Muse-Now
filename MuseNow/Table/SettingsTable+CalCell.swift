//  SettingsTable+CalCell.swift

import EventKit
import UIKit

extension SettingsTableVC {
    
    func updateCellMarks() {
        for cell in tableView.visibleCells {
            if cell is CalCell {
                let cell = cell as! CalCell
                cell.mark.setMark(cell.isShowCal)
            }
        }
    }
}
