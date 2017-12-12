//
//  EventTable+MuEvent.swift

import UIKit

extension EventTableVC {
    
    /// update indexPath for cell
    /// - via: self.scroll(View|Select)event
    @discardableResult
    func setPathForEvent(_ event: MuEvent) -> UITableViewCell! {
        
        for cell in tableView.visibleCells {
            
            let museCell = cell as! MuCell
            if museCell.event.eventId == event.eventId {
                
                prevIndexPath = tableView.indexPath(for: museCell)!
                //print("📅 \(#function): \(museCell.event.title)")
                return cell
            }
        }
        //print("📅 \(#function) not found ***")
        return nil
    }
    
    
    /// reposition table with event in center and highlight cell
    /// - via: Scene.update.(scanning marking)
    func scrollSceneEvent(_ event: MuEvent) {
        
        // if duplicate event is still on screeen
        if scrollingEventIsVisible(event) { return }
        
        //let height = tableView.frame.size.height
        
        if let rowItem = rowItemId[event.eventId] {

            scrollingEvent = event
            
            //print("\(#function): \(event.title) posY:\(posY)")
            let scrollY = rowItem.posY // - rowHeight/2 // - tableHeaderH
            UIView.animate(withDuration: 0.5, delay: 0.0, options: [.curveEaseInOut, .allowUserInteraction, .beginFromCurrentState],
                           animations: {
                            self.tableView.contentOffset.y = scrollY
            },
                           completion: { _ in
                            if let cell = self.setPathForEvent(event) {
                                self.nextDialCell(cell as! MuCell)
                            }
            })
        }
    }


    func scrollingEventIsVisible(_ event: MuEvent) -> Bool {
        // if duplicate event is still on screeen
        if let scrollingEvent = scrollingEvent,
            scrollingEvent.eventId == event.eventId,
            scrollingEvent.type != .time,
            prevCell != nil {

            return true
        }
        return false
    }

    /**
        reposition table with event in center
        - via: Anim.touchDialPan
    */
    func scrollDialEvent(_ event: MuEvent,_ delta: Int) {
        
        if scrollingEventIsVisible(event) { return }
        if prevCell != nil && prevCell.event.eventId == event.eventId {
            //print("", terminator:"˚")
            return
        }

        if let rowItem = rowItemId[event.eventId] {
            
            scrollingEvent = event
            
            let scrollY = rowItem.posY - rowHeight/2
            
            //print ("--> \(#function): \(event.title) scrollY:\(scrollY) delta:\(delta)")
            
            UIView.animate(withDuration: 0.5, delay: 0.0,  options: [.curveEaseInOut, .allowUserInteraction, .beginFromCurrentState],
                           animations: {
                            self.tableView.contentOffset.y = scrollY
            },
                           completion: { finished in
                            if finished {
                                if let cell = self.setPathForEvent(event) {
                                    self.nextDialCell(cell as! MuCell)
                                }
                            }
            })
        }
    }
    
}
