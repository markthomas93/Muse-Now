
import WatchKit

class MenuColorTitleMark: MenuTitleMark {

    @IBOutlet var color: WKInterfaceGroup!

    @IBAction func MenuColorTitleMarkAction() {
        treeNode.toggle()
        Log("▤ \(#function)")
    }
    // color dot
    func setColor(_ rgb: UInt32) {
        color?.setBackgroundColor(MuColor.getUIColor(rgb))
    }
 }

