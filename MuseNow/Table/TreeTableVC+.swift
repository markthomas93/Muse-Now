//  SettingsTable.swift

import UIKit
import EventKit


extension TreeTableVC {

    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        //printLog("⿳ scrollViewDidScroll: \(self.tableView.contentOffset.y)")
    }
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let rows = TreeNodes.shared.shownNodes.count
        //printLog("⿳ numberOfRowsInSection: \(rows)")
        return rows
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return nil
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let row = indexPath.row
        let node = TreeNodes.shared.shownNodes[row]
        if let height = node?.cell?.height {
            return height
        }
        return rowHeight
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        var shownRowsHeight = CGFloat(0)
        var shownChild = false
        nodes: for node in TreeNodes.shared.shownNodes {
            switch node?.getParentChildOther() {
            case .child?: shownChild = true
            default: if shownChild {
                break nodes
                }
            }
            if let cell = node?.cell {
                shownRowsHeight += cell.height
            }
        }
        headerY = max(0,tableView.bounds.height - shownRowsHeight)
         printLog("⿳ heightForHeaderInSection: \(headerY)")
        return headerY
    }

    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        var shownRowsHeight = CGFloat(0)
        for node in TreeNodes.shared.shownNodes {
            if let cell = node?.cell {
                shownRowsHeight += cell.height
            }
        }
        let height = max(0,tableView.bounds.height - shownRowsHeight)
        return height
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return nil
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let row = indexPath.row
        if let node = TreeNodes.shared.shownNodes[row] {
            //printLog("⿳ cellForRowAt:\(row) title:\(node.cell.title.text!)")
            return node.cell
        }
        return UITableViewCell()
    }

}
