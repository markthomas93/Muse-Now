//  TimeCell.swift

import UIKit

class EventTimeCell: MuCell {
    
    var time: UILabel!
    let rowHeight = CGFloat(44)
    let sectionHeight = CGFloat(36)
    
    func setCellEvent(_ event_: MuEvent!, _ size: CGSize) {
    
        selectionStyle = UITableViewCellSelectionStyle.none
        event = event_ // not really needed
        
        backgroundColor = cellColor
        contentView.backgroundColor = cellColor
        contentView.frame.size = size
        
        // time hour:Min
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm a"
        let hourStr = dateFormatter.string(from: Date())
        
        let timeWidth = size.width / 2
        let timeFrame = CGRect(x:(size.width - timeWidth) / 2,
                               y:(size.height - sectionHeight) / 2,
                               width: timeWidth,
                               height: sectionHeight)
        time = UILabel(frame:timeFrame)
        
        time.text = hourStr
        time.textColor = .white
        time.backgroundColor = .black
        time.highlightedTextColor = .white
        time.font = UIFont(name: "Helvetica Neue", size: 22)!
        time.textColor = .white
        time.textAlignment = .center
        
        // bezel for time
        time.layer.cornerRadius = sectionHeight/2
        time.layer.borderColor = headColor.cgColor
        time.layer.borderWidth = 1
        time.layer.masksToBounds = true
        
        setHighlight(false, animated:false)
        
        contentView.addSubview(time)
    }
    
    override func setHighlight(_ isHighlight_:Bool, animated:Bool = true) {
        
        isHighlight = isHighlight_
        
        let fromColor = isHighlight ?  UIColor.darkGray.cgColor :  UIColor.white.cgColor
        let toColor   = isHighlight ?  UIColor.white.cgColor :  UIColor.darkGray.cgColor
        
        if animated {
            animateBorderColor(time,   fromColor, toColor, duration: 0.25)
        }
        else {
            time.layer.borderColor    = toColor
        }
        if !isHighlight {
            isSelected = false
        }
    }
}
