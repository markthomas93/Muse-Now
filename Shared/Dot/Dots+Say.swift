
import UIKit

extension Dots {
    
    
    /// while scanning, announce a dot's first marked event
    /// - via: Scene.update.scanning
    
    func sayFirstMark(_ index: Int, _ clockwise: Bool) -> MuEvent! {
        
        if let event = getDot(index).getFirstMark(clockwise) {
            
            dayHour.setIndexForEvent(event)
            say.sayDotEvent(event, isTouching:false)
            return event
        }
        return nil
    }
    
    /// after first event, announce a dot's next marked occurring event
    /// - via: Scene.update.marking
    
    func sayNextMark(_ index: Int, _ clockwise: Bool) -> MuEvent! {
        
        if index != LONG_MAX {
            
            if let event = getDot(index).getNextMark(clockwise) {
                
                dayHour.setIndexForEvent(event)
                say.sayDotEvent(event, isTouching:false)
                return event
            }
        }
        return nil
    }
    
    
}
