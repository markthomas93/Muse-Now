// Dots+Mark.swift

import UIKit

extension Dots {

    /**
     While scanning, announce a dot's first marked event
     - via: Scene.update.scanning
     */
    func sayFirstMark(_ index: Int) -> MuEvent! { // Log("⚇ \(#function) \(index)")
        
        if let event = getDot(index).getFirstMark(index,isClockwise) {
            
            dayHour.setIndexForEvent(event)
            Say.shared.sayDotEvent(event, isTouching:false)
            return event
        }
        return nil
    }

    /**
     After first event, announce a dot's next marked occurring event
     - via: Scene.update.marking
     */
    func sayNextMark(_ index: Int) -> MuEvent! { // Log("⚇ \(#function) \(index)")
        
        if let event = getDot(index).getNextMark(index, isClockwise) {

            dayHour.setIndexForEvent(event)
            Say.shared.sayDotEvent(event, isTouching:false)
            return event
        }
        return nil
    }
}
