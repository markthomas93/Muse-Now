import UIKit

let timeHeight    = CGFloat(44)         //
let rowHeight     = CGFloat(44)         // timeHeight * (1 + 1/phi2)
let sectionHeight = CGFloat(32)         // rowHeight * (1 + 1/phi2)
let footerHeight  = CGFloat(18)

class EventTableVC: UITableViewController, MuseTableDelegate {

    let say = Say.shared
    let anim = Anim.shared
    
    var scene: Scene!
   
    var dateEvents    = [Date:[MuEvent]]()  // edit select update
    var sectionDate   = [Date]()            // edit select update
    var sectionTitles = [String]()          // update
   
    var rowItemId = [String:EventRowItem]()  // scroll crown select update
    var rowItems  = [EventRowItem]()        // for timeCell and contentOffset.y updates
    var timeRowi  = Int(0)              // position of TimeCell in rowEventY array
    var timeCell  : EventTimeCell!      // cell shows current time, keep changing its position
    var cellTimer = Timer()             // 1 minute time to change timeCell label and maybe position

    var sayTimer   = Timer()           // delay saying anything while navigating
    

    let cal = Calendar.current as NSCalendar
    
    var prevCell: MuCell!                   // Select + PhoneCrown + EditRow + MuEvent
    var prevIndexPath: IndexPath!           // Select + PhoneCrown + EditRow + MuEvent
    var timeIndexPath: IndexPath!

    var prevOffsetY = CGFloat(0)            // Scroll
    var isDragging = false                  // user is Scrolling manually
    
    var scrollingEvent: MuEvent!            // EventTable+MuEvent: prevent duplicate scrollDialEvent
    var updating = false
    var tableHeaderH = CGFloat(0)
    var tableFooterH = CGFloat(0)

    override func viewWillAppear(_ animated: Bool) {
         PhoneCrown.shared?.setDelegate(self)
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return sectionDate.count
    }


    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        if tableView.tableHeaderView == nil {
            tableHeaderH = tableView.bounds.height / 2
            let headerFrame = CGRect(x:0,y:0,width:tableView.bounds.width,height:tableHeaderH)
            let headerView = UIView(frame:headerFrame)
            headerView.backgroundColor = .clear
            headerView.setNeedsUpdateConstraints()
            headerView.updateConstraintsIfNeeded()
            self.tableView.tableHeaderView = headerView
        }
        if tableView.tableFooterView == nil {
            tableFooterH = tableView.bounds.height / 2 - rowHeight
            let footerFrame = CGRect(x:0,y:0,width:tableView.bounds.width,height:tableFooterH)
            let footerView = UIView(frame:footerFrame)
            footerView.backgroundColor = .clear
            footerView.setNeedsUpdateConstraints()
            footerView.updateConstraintsIfNeeded()
            self.tableView.tableFooterView = footerView
        }
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section < sectionDate.count {
            
            let date = sectionDate[section]
            let count = dateEvents[date]!.count
            //printLog("⿳ section:\(section) rows:\(count)")
            return count
        }
        return 0
    }
    
    func eventFromIndexPath(_ indexPath: IndexPath) -> MuEvent? {
        
        let date = sectionDate[indexPath.section]
        let events = dateEvents[date]
        if let event = events?[indexPath.row] {
            return event
        }
        return nil
    }
    
    func removeCell(path:IndexPath) {
        
        var paths = self.tableView.indexPathsForVisibleRows
        for i in 0 ..< (paths?.count)! {
            if paths?[i] == path {
                paths?.remove(at: i)
            }
        }
        tableView.beginUpdates()
        tableView.reloadRows(at: paths!, with: UITableViewRowAnimation.automatic)
        tableView.endUpdates()
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
        view.roundCorners([UIRectCorner.topRight, UIRectCorner.topLeft], radius: sectionHeight/2)
        return view
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if timeIndexPath != nil && timeIndexPath == indexPath {
            return timeHeight
        }
        else {
            return rowHeight
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return sectionHeight
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionTitles[section]
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let event = eventFromIndexPath(indexPath)
        
        switch (event?.type)! {
            
        case .time:
            timeCell = tableView.dequeueReusableCell(withIdentifier: "EventTimeCell")! as! EventTimeCell
            if let event = event {
                let size = CGSize(width: view.frame.size.width, height: timeHeight)
                timeCell.setCell(event:event,size)
                timeCell.frame.size.width = view.frame.size.width
                timeIndexPath = indexPath
            }
            return roundCorners(timeCell,indexPath)
            
        default:
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "EventCell")! as! EventCell
            // if prevCell is offscreen and recycled, then set it nil
            if prevCell != nil && prevCell == cell { prevCell = nil }
            cell.setCell(event:event,tableView)
            cell.frame.size.width = view.frame.size.width
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
    
}
