//  CalTable.swift

import UIKit
import EventKit

class CalTableVC: UITableViewController {
    
    let koEvents = KoEvents.shared
    let faderHeight   = CGFloat(66)
    let rowHeight     = CGFloat(44)         // timeHeight * (1 + 1/phi2)
    let sectionHeight = CGFloat(32)         // rowHeight  * (1 + 1/phi2)
     
    var prevCell: KoCell!
    var prevIndexPath: IndexPath!      // Select + PhoneCrown + EditRow + KoEvent
    var updating = false
    
    var faderIndex = 1
    var colorCell: ColorCell!
    
    var scrollView :  UIScrollView!
 
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
     }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        faderIndex = Cals.shared.sourceCals.count
        return faderIndex + 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sourceCals = Cals.shared.sourceCals
        let keys = Array(sourceCals.keys)
        
        if section < keys.count {
            let key = keys[section]
            let array = sourceCals[key]!
            return array.count
        }
        else if section == faderIndex {
            return 1
        }
        else  {
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {

        guard let header = view as? UITableViewHeaderFooterView else { return }
        
        header.contentView.backgroundColor = headColor
        if let label = header.textLabel {
            label.font = UIFont(name: "Helvetica Neue", size: 16)!
            label.textColor = textColor
            label.shadowColor = UIColor.black
            label.shadowOffset = CGSize(width: 0.5, height: 1)
        }
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let view = UITableViewHeaderFooterView()
        
        view.bounds = CGRect(x:0,y:0,width:tableView.frame.size.width, height:sectionHeight)
        view.roundCorners([UIRectCorner.topRight, UIRectCorner.topLeft], radius: sectionHeight/4)
        return view
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return rowHeight
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return sectionHeight
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        if section == faderIndex {
            return "Color"
        }
        else {
            let keys = Array(Cals.shared.sourceCals.keys)
            let title = keys[section]
            return title
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let width = self.view.frame.size.width
        
        if indexPath.section == faderIndex {
            if colorCell != nil { return colorCell }
            colorCell = tableView.dequeueReusableCell(withIdentifier: "ColorCell")! as! ColorCell
            colorCell.frame.size.width = width
            let faderFrame = CGRect(x:44, y:4, width: width-88, height:rowHeight-8)
            let fader = Fader(frame:faderFrame)
            
            fader.tableView = tableView
            colorCell.setCellFader(fader)
            return roundCorners(colorCell, indexPath)
        }
        else  {
            let cell = tableView.dequeueReusableCell(withIdentifier: "CalCell")! as! CalCell
            let values = Array(Cals.shared.sourceCals.values)
            let cals = values[indexPath.section]
            let cal = cals[indexPath.row]
            
            // if prevCell is offscreen and recycled, then set it nil
            if prevCell != nil && prevCell == cell { prevCell = nil }
            cell.setCellCalendar(cal,CGSize(width:width, height:rowHeight))
            return roundCorners(cell, indexPath)
        }
        
    }
    
    // bottom cell has rounded corners
    func roundCorners(_ cell:UITableViewCell,_ indexPath:IndexPath) -> UITableViewCell {
        
        let rows = self.tableView(tableView, numberOfRowsInSection: indexPath.section)
        if indexPath.row == rows-1 {
            cell.roundCorners([UIRectCorner.bottomLeft,UIRectCorner.bottomRight],
                              radius: sectionHeight/2)
        }
        else {
            cell.layer.mask = nil
        }
        return cell
    }

    
    // UITableView Delegate --------------------------------------------------
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {//printLog("⿳ \(#function)")
        
        if indexPath.section == faderIndex {
            clearPrevCell()
        }
        else if let cell = tableView.cellForRow(at: indexPath) {
            if cell != prevCell {
                nextKoCell(cell as! KoCell)
                prevIndexPath = indexPath
            }
        }
    }
    
}
