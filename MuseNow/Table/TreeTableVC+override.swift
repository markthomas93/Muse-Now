//  SettingsTable.swift

import UIKit
import EventKit


extension TreeTableVC {

    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        //Log("▤ scrollY: \(Int(self.tableView.contentOffset.y))")
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let rows = TreeNodes.shared.shownNodes.count
        //Log("▤ numberOfRowsInSection: \(rows)")
        return rows
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return nil
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let row = indexPath.row
        let node = TreeNodes.shared.shownNodes[row]
        if let height = node.cell?.height {
            return height
        }
        return rowHeight
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        var shownRowsHeight = CGFloat(0)
        for node in TreeNodes.shared.shownNodes {
            if let cell = node.cell {
                shownRowsHeight += cell.height
            }
        }
        shownRowsHeight += 44 //?? Kludge fixup after expanding and contracting -- scrolls beyond tableView.bounds
        let middle = tableView.bounds.height / 2
        headerY = max(middle,tableView.bounds.height - shownRowsHeight)
        //headerY = max(0,tableView.bounds.height - shownRowsHeight)
        Log("▤ heightForHeaderInSection: \(headerY)")
        return headerY
    }

    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 8
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return nil
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let row = indexPath.row
        let shownNodes = TreeNodes.shared.shownNodes
        if row < shownNodes.count {
            let node = shownNodes[row]
            //Log("▤ cellForRowAt:\(row) title:\(node.cell.title.text!)")
            return node.cell
        }
        return UITableViewCell()
    }

}
