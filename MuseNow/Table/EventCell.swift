//  KoEentCell.swift

import UIKit

class EventCell: MuCell {

    let rowHeight = CGFloat(36)         // timeHeight * (1 + 1/phi2)

    @IBOutlet weak var bezel: UIView!
    @IBOutlet weak var color: UIImageView!
    @IBOutlet weak var time:  UILabel!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var mark:  ToggleDot!
    
    func setCell(event event_: MuEvent!, _ tableView: UITableView!) {
        
        event = event_
        mark.setMark(event.mark)
        contentView.backgroundColor = cellColor
        
        // color dot
        color.image = UIImage.circle(diameter: 10, color:MuColor.getUIColor(event.rgb))
        
        // hour:Min
        let bgnDate = Date(timeIntervalSince1970:event.bgnTime)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm a"
        let hourStr = dateFormatter.string(from: bgnDate)
        
        time.text = hourStr
        time.textColor = .lightGray
        time.highlightedTextColor = .darkGray
        
        // title
        title.text = event.title
        title.textColor = .white
        title.highlightedTextColor = .black
        
        // bezel for title
        bezel.layer.cornerRadius = rowHeight/2
        bezel.layer.borderWidth = 1
        bezel.layer.masksToBounds = true
        
        setHighlight(false, animated:false)
    }

    override func setHighlight(_ isHighlight_:Bool, animated:Bool = true) {
        
        isHighlight = isHighlight_
        
        let index = isHighlight ? 1 : 0
        let borders     = [cellColor.cgColor, UIColor.white.cgColor]
        let backgrounds = [cellColor.cgColor, UIColor.black.cgColor]

        if animated {
            animateViews([bezel,mark], borders, backgrounds, index, duration: 0.25)
        }
        else {
            bezel.layer.borderColor     = borders[index]
            mark.layer.borderColor      = borders[index]
            bezel.layer.backgroundColor = backgrounds[index]
            mark.layer.backgroundColor  = backgrounds[index]
        }
        if !isHighlight {
            isSelected = false
        }
    }
    
    
    override func touchCell(_ location: CGPoint) {

        if let tableVC = tableVC as? TreeTableVC {
            tableVC.touchedCell = self
        }
        let toggleX = frame.size.width -  frame.size.height*1.618
        if location.x > toggleX {

            event.mark = !(event.mark)
            mark?.setMark(event.mark)
            let act = event.mark ? DoAction.markOn : DoAction.markOff
            let index = Dots.shared.gotoEvent(event)
            Actions.shared.doAction(act, event, index, isSender: true)
        }
        else if event.type == .memo {

                Say.shared.sayDotEvent(event, isTouching: true)
        }
         Anim.shared.touchDialGotoTime(event.bgnTime)
    }

}

