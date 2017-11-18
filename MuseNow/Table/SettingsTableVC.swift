//  SettingsTable.swift

import UIKit
import EventKit

class SettingsTableVC: UITableViewController {
    
    var cells : [String:MuCell] = [:]
    
    let faderHeight   = CGFloat(66)
    let rowHeight     = CGFloat(44)         // timeHeight * (1 + 1/phi2)
    let sectionHeight = CGFloat(32)         // rowHeight  * (1 + 1/phi2)
    var showingCals   = true                // displaying last known state of Show.shared.canShow(.showCalendar)

    var prevCell: MuCell!
    var prevIndexPath: IndexPath!      // Select + PhoneCrown + EditRow + MuEvent
    var updating = false
    var showIndex = 0
    var sayIndex = 1
    var hearIndex = 2
    var colorIndex = 3
    
    var colorCell: ColorCell!
    
    var scrollView :  UIScrollView!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        showingCals = Show.shared.canShow(.showCalendar)
    }

    func updateShowCalendars() {

        let showingNext = Show.shared.canShow(.showCalendar)
        let count = Cals.shared.sourceCals.count

        if showingCals && !showingNext {
            showingCals = showingNext
            tableView.deleteSections(IndexSet(0..<count), with: .top)
        }
        else if !showingCals && showingNext {
            showingCals = showingNext
            tableView.insertSections(IndexSet(0..<count), with: .top)
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

    override func numberOfSections(in tableView: UITableView) -> Int {
        
        showIndex = Show.shared.canShow(.showCalendar) ? Cals.shared.sourceCals.count : 0
        sayIndex = showIndex + 1
        hearIndex = sayIndex + 1
        colorIndex = hearIndex + 1
        return colorIndex + 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sourceCals = Cals.shared.sourceCals
        let keys = Array(sourceCals.keys)
        
        switch section {
        case showIndex: return ShowSet.size
        case sayIndex: return SaySet.size
        case hearIndex: return HearSet.size
        case colorIndex: return 1
        default:
            if Show.shared.canShow(.showCalendar),
                let array = sourceCals[keys[section]] {
                return array.count
            }
            else  {
                return 0
            }
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
        
        switch section {
        case showIndex:     return "Show"
        case colorIndex:    return "Color"
        case hearIndex:     return "Hear"
        case sayIndex:      return "Say"
        default:
            
            let keys = Array(Cals.shared.sourceCals.keys)
            let title = keys[section]
            return title
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let width = self.view.frame.size.width
        let index = indexPath.row
        
        switch indexPath.section {
            
        case showIndex:

            let cell =  SettingsCell(setting:ShowSetting(index, Show.shared.showSet.rawValue), /*level*/ 0, CGSize(width:width, height:rowHeight))
            if prevCell != nil && prevCell == cell { prevCell = nil }
            return roundCorners(cell, indexPath)

        case hearIndex:

            let cell = SettingsCell(setting:HearSetting(index, Hear.shared.hearSet.rawValue), /*level*/ 0, CGSize(width:width, height:rowHeight))
            if prevCell != nil && prevCell == cell { prevCell = nil }
            return roundCorners(cell, indexPath)

        case sayIndex:
            
            let cell = SettingsCell(setting:SaySetting(index, Say.shared.saySet.rawValue), /*level*/ 0, CGSize(width:width, height:rowHeight))
            if prevCell != nil && prevCell == cell { prevCell = nil }
            return roundCorners(cell, indexPath)
            
        case colorIndex:
            
            let value = Settings.shared.root["dialColor"] as? Float ?? 0
            if colorCell != nil { return colorCell }
            colorCell = tableView.dequeueReusableCell(withIdentifier: "ColorCell")! as! ColorCell
            colorCell.frame.size.width = width
            let faderFrame = CGRect(x:44, y:4, width: width-88, height:rowHeight-8)
            let fader = Fader(frame:faderFrame,tableView,value)
            colorCell.setCell(fader:fader)
            return roundCorners(colorCell, indexPath)
            
        default:

            let cell = tableView.dequeueReusableCell(withIdentifier: "CalCell")! as! CalCell
            let values = Array(Cals.shared.sourceCals.values)
            let cals = values[indexPath.section]
            let cal = cals[index]
            // if prevCell is offscreen and recycled, then set it nil
            if prevCell != nil && prevCell == cell { prevCell = nil }
            cell.setCell(calendar:cal,CGSize(width:width, height:rowHeight))
            return roundCorners(cell, indexPath)
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {//printLog("⿳ \(#function)")
        
        if indexPath.section == colorIndex {
            clearPrevCell()
        }
        else if let cell = tableView.cellForRow(at: indexPath) {
            if cell != prevCell {
                nextMuCell(cell as! MuCell)
                prevIndexPath = indexPath
            }
        }
    }
    
}
