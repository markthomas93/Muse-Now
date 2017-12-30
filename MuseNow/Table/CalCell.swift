//  CalCell.swift


import UIKit
import EventKit

class CalCell: MuCell {
    
    var cal: Cal!
    var isShowCal = true
 
    @IBOutlet weak var bezel: UIView!
    @IBOutlet weak var color: UIImageView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var mark: ToggleCheck!
    
    func setCell(calendar: Cal!,_ size:CGSize) {
        
        cal = calendar
        self.frame.size = size
        contentView.backgroundColor = cellColor
        
        let innerH = CGFloat(36)    // inner height
        let dotW = CGFloat(10)
        
        // dot
        color.image = UIImage.circle(diameter: dotW, color:UIColor(cgColor:cal.color))
        
        // title
        title.text = cal.title
        title.textColor = .white
        title.highlightedTextColor = .black
        
        // bezel for title
        bezel.layer.cornerRadius = innerH/4
        bezel.layer.borderWidth = 1
        bezel.layer.masksToBounds = true
        
        // bezel for mark
        mark.layer.cornerRadius = innerH/4
        mark.layer.borderWidth = 1.0
        mark.layer.masksToBounds = true
        mark.setMark(cal.isOn)
        
        setHighlight(false, animated:false)
    }
    
    override func setHighlight(_ highlighting_:Highlighting, animated:Bool = true) {
        
        if highlighting != highlighting_ {
            var index = 0
            switch highlighting_ {
            case .high,.forceHigh: highlighting = .high ; index = 1 ; isSelected = true
            default:               highlighting = .low  ; index = 0 ; isSelected = false
            }
            let borders     = [headColor.cgColor, UIColor.white.cgColor]
            let backgrounds = [UIColor.black.cgColor, UIColor.black.cgColor]
            
            if animated {
                animateViews([bezel,mark], borders, backgrounds, index, duration: 0.25)
            }
            else {
                bezel.layer.borderColor     = borders[index]
                mark.layer.borderColor      = borders[index]
                bezel.layer.backgroundColor = backgrounds[index]
                mark.layer.backgroundColor  = backgrounds[index]
            }
        }
        else {
            switch highlighting {
            case .high,.forceHigh: isSelected = true       
            default:               isSelected = false
            }
        }
    }
    
    override func touchCell(_ location: CGPoint, isExpandable:Bool = true) {

        let toggleX = frame.size.width -  frame.size.height*1.618
        if location.x > toggleX {

            isShowCal = !isShowCal
            mark?.setMark(isShowCal)
            
            Cals.shared.updateMark(cal.calId, isShowCal)
            Session.shared.sendMsg( [ "class" : "Calendars",
                                      "calId" : cal.calId,
                                      "isOn"  : isShowCal])
        }
    }
    
}

