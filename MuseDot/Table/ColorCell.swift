//  ColorCell.swift


import UIKit
import EventKit

class ColorCell: UITableViewCell {
    
    var fader: Fader!
    
    func setCell(fader fader_: Fader) {
        
        fader = fader_
        contentView.backgroundColor = cellColor
        self.addSubview(fader)
    }
    
}
