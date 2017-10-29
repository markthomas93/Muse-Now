//  ColorCell.swift


import UIKit
import EventKit

class ColorCell: UITableViewCell {
    
    var fader: Fader!
    
    func setCellFader(_ fader_: Fader) {
        
        fader = fader_
        contentView.backgroundColor = cellColor
        self.addSubview(fader)
    }
    
}
