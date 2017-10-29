// EventTable+EditRow.swift

// When user slide a row, reveal option
// currently a placeholder that duplicates tapping on checkmark

import UIKit

extension EventTableVC {
    
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return prevIndexPath != nil && indexPath == prevIndexPath!
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let date = sectionDate[indexPath.section]
        let events = dateEvents[date]
        let event = events?[indexPath.row]
        if let cell = tableView.cellForRow(at: indexPath) {
            let klioCell = cell as! EventCell
            if (event?.mark)! {
                let rowAction = UITableViewRowAction(style: UITableViewRowActionStyle.normal, title: "⊗" , handler: { (action:UITableViewRowAction, indexPath:IndexPath) -> Void in
                    
                    event?.mark = false
                    klioCell.mark?.setMark(false)
                    tableView.setEditing(false, animated: true)
                    
                })
                rowAction.backgroundColor = .black
                return [rowAction]
            }
            else {
                let rowAction = UITableViewRowAction(style: UITableViewRowActionStyle.normal, title: "⊕" , handler: { (action:UITableViewRowAction, indexPath:IndexPath) -> Void in
                    
                    event?.mark = true
                    klioCell.mark?.setMark(true)
                    tableView.setEditing(false, animated: true)
                    
                })
                rowAction.backgroundColor = .black
                return [rowAction]
            }
            
        }
        return []
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
    }
    
}
