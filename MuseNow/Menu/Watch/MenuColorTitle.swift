//  CalCell.swift

import WatchKit

class MenuColorTitle: MenuTitle {

    @IBOutlet var color: WKInterfaceGroup!

    // color dot
    func setColor(_ rgb: UInt32) {
        color?.setBackgroundColor(MuColor.getUIColor(rgb))
    }
}

