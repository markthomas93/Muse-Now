// EventTable+Update.swift

import UIKit

extension EventTableVC {

    func updateTable(_ events: [MuEvent]) {

        updating  = true // don't allow user interaction while updating table
        
        sectionDate.removeAll()
        sectionTitles.removeAll()
        rowItemId.removeAll()
        dateEvents.removeAll()
        
        var posY = CGFloat(0)

        for event in events {

            if event.type == .routine && !Show.shared.routList {
                continue
            }

            let bgnDate = Date(timeIntervalSince1970:event.bgnTime)
            let bgnDayComps = cal.components([.year, .month, .day, .timeZone], from: bgnDate)
            let bgnDayDate  = cal.date(from: bgnDayComps)
            
            if dateEvents[bgnDayDate!] != nil {
                dateEvents[bgnDayDate!]!.append(event)
            }
            else {
                dateEvents[bgnDayDate!] = [event]
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "E MMM dd"
                let dateStr = dateFormatter.string(from: bgnDayDate!)
                sectionDate.append(bgnDayDate!)
                sectionTitles.append(dateStr)

                let rowTime = bgnDayDate!.timeIntervalSince1970
                let rowItem = EventRowItem(rowTime,dateStr,posY)
                rowItems.append(rowItem)
                rowItemId[rowItem.getId()] = rowItem
                posY += sectionHeight + footerHeight
            }
            // save index for current time cell to enable changes to position in table
            if event.type == .time {
                timeRowi = rowItems.count
            }
            let rowItem = EventRowItem(event,posY)
            rowItems.append(rowItem)
            rowItemId[rowItem.getId()] = rowItem
            posY += rowHeight
        }
        self.tableView.reloadData()
        updating = false
    }
}
