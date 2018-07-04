//  EventTable+TimeCell.swift

import UIKit

extension EventTableVC {
    
    func getRelativeIndexPath(_ cell: UITableViewCell, _ delta: Int) -> IndexPath! {
        
        if let cellPath = tableView.indexPath(for: cell) {
            
            var rowi = cellPath.row
            var seci = cellPath.section
            
            if delta < 0 {
                for _ in delta ..< 0 {
                    rowi -= 1
                    if rowi < 0 {
                        seci -= 1
                        if seci < 0 {
                            return nil
                        }
                        let date = sectionDate[seci]
                        let rows = dateEvents[date]!.count
                        rowi = rows - 1
                    }
                }
                return IndexPath(row: rowi, section: seci)
            }
            else if delta > 0 {
                
                var date = sectionDate[seci]
                var rows = dateEvents[date]!.count
                
                for _ in 0 ..< delta {
                    rowi += 1
                    if rowi >= rows {
                        seci += 1
                        if seci > sectionDate.count {
                            return nil
                        }
                        date = sectionDate[seci]
                        rows = dateEvents[date]!.count
                        rowi = 0
                    }
                }
                return IndexPath(row: rowi, section: seci)
            }
            else {
                return cellPath
            }
        }
        return nil
    }
    
    // TimeEventDelegate
    
    /// handle special .time event, which changes
     ///  1) Title every minute
     ///  2) position relative to other events in model, based on time
     ///  3) position in sections and rows, based on time
     /// - via: EventVC.minuteTimerTick()

    func updateTimeEvent() {

        if  let timeCell = timeCell,
            let timeEvent = timeCell.event,
            let timeRowItem = rowItemId[timeEvent.eventId]  {

            Dots.shared.updateTime(event: timeEvent)
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "h:mm a"
            let hourStr = dateFormatter.string(from: Date())
            timeCell.time?.text = hourStr

            // check to see if new minute changes timeCells position in table
            var count = 0
            var lastMovedRowItem = rowItems[timeRowi]
            for rowi in timeRowi+1 ..< rowItems.count {

                if rowItems[rowi].isAfterTime(timeEvent.bgnTime)  {
                    break
                }
                lastMovedRowItem = rowItems[rowi]
                // section header in
                Log("⌛️ timeRowi:\(timeRowi) rowi:\(rowi)")
                rowItems[rowi].posY -= timeHeight
                count += 1
            }
            
            // no more rows to shift above time, so now animate and update model
            if count > 0 {

                let nextFreeY = lastMovedRowItem.nextFreeY()
                timeRowItem.posY = nextFreeY

                rowItems.remove(at: timeRowi)
                timeRowi += count
                rowItems.insert(timeRowItem, at: timeRowi)
                
                if let srcPath = tableView.indexPath(for: timeCell) {
                    if var dstPath = getRelativeIndexPath(timeCell,count) {
                        
                        let srcDate = sectionDate[srcPath.section]
                        let dstDate = sectionDate[dstPath.section]
                        dateEvents[srcDate]?.remove(at:srcPath.row)
                        dateEvents[dstDate]?.insert(timeEvent, at:dstPath.row)
                        
                        tableView.beginUpdates()
                        timeIndexPath = dstPath
                        tableView.moveRow(at: srcPath, to: dstPath)
                        tableView.endUpdates()
                    }
                }
            }
        }
    }
}
