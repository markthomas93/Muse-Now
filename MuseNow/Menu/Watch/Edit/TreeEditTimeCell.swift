import UIKit
import EventKit

class TreeEditTimeCell: TreeEditCell {

//    // Time Picker
//    var bgnTimePicker:  UIPickerView! // time of day to begin
//    var bgnLabel:       UILabel! // time of day to begin
//    var bgnTimeFrame    = CGRect.zero
//
//    var endTimePicker:  UIPickerView! // time of day to begin
//    var endLabel:       UILabel! // time of day to begin
//    var endTimeFrame    = CGRect.zero
//
//    var arrowLabel:     UILabel!
//    var arrowFrame      = CGRect.zero
//
//    var hours = ["00","01","02","03","04","05","06","07","08","09", "10","11","12","13","14","15","16","17","18","19", "20","21","22","23"]
//    var mins = ["00","05","10","15","20","25","30","35","40","45","50","55"]

    convenience required init(coder decoder: NSCoder) {
        self.init(coder: decoder)
    }

    convenience init(_ treeNode_: TreeNode!) {

        self.init()

        treeNode = treeNode_

        let tableVC = TreeNodes.shared.vc as! UITableViewController
         tableView = tableVC.tableView

        buildViews(width)
    }

    override func buildViews(_ width: CGFloat) {
        
        super.buildViews(width)

      }
 }

















