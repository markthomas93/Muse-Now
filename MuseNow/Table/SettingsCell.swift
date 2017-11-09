//  CalCell.swift


import UIKit
import EventKit

class SettingsCell: MuCell {

    var setting: Setting!
 
    @IBOutlet weak var bezel: UIView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var mark: ToggleCheck!
    
    func setCellSetting (_ setting_: Setting!,_ size:CGSize) {
        
        setting = setting_
        self.frame.size = size
        contentView.backgroundColor = cellColor
        
        let innerH = CGFloat(36)    // inner height
        
        // title
        title.text = setting.title
        title.textColor = .white
        title.highlightedTextColor = .black

        // make this cell searchable within static cells
        PagesVC.shared.calTable.cells[setting.title] = self

        // bezel for title
        bezel.layer.cornerRadius = innerH/4
        bezel.layer.borderWidth = 1
        bezel.layer.masksToBounds = true
        
        // bezel for mark
        mark.layer.cornerRadius = innerH/4
        mark.layer.borderWidth = 1
        mark.layer.masksToBounds = true
        mark.setMark(setting.isOn)
        
        setHighlight(false, animated:false)
    }

    override func setHighlight(_ isHighlight_:Bool, animated:Bool = true) {
        
        isHighlight = isHighlight_
        
        let index       = isHighlight ? 1 : 0
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
    
    override func touchMark() {

        setting.flipSet()
        mark.setMark(setting.isOn)
    }
    
    override func touchTitle() {
    
    }
}

