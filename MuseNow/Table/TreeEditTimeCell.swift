import UIKit
import EventKit

class TreeEditTimeCell: TreeEditCell {

    // Time Picker
    var bgnTimePicker:  UIPickerView! // time of day to begin
    var bgnLabel:       UILabel! // time of day to begin
    var bgnTimeFrame    = CGRect.zero

    var endTimePicker:  UIPickerView! // time of day to begin
    var endLabel:       UILabel! // time of day to begin
    var endTimeFrame    = CGRect.zero

    var arrowLabel:     UILabel!
    var arrowFrame      = CGRect.zero

    var hours = ["00","01","02","03","04","05","06","07","08","09", "10","11","12","13","14","15","16","17","18","19", "20","21","22","23"]
    var mins = ["00","05","10","15","20","25","30","35","40","45","50","55"]

    convenience required init(coder decoder: NSCoder) {
        self.init(coder: decoder)
    }

    convenience init(_ treeNode_: TreeNode!, _ tableVC_:UITableViewController) {
        self.init()
        tableVC = tableVC_
        frame.size = CGSize(width:tableVC.view.frame.size.width, height:height)
        treeNode = treeNode_
        buildViews(frame.size)
    }

    override func buildViews(_ size: CGSize) {
        
        super.buildViews(size)
        // start hour:Min
        bgnTimePicker = UIPickerView(frame:bgnTimeFrame)
        bgnTimePicker.delegate = self
        bgnTimePicker.dataSource = self
        bgnTimePicker.setValue(UIColor.white, forKey:"textColor")
        bgnTimePicker.backgroundColor = .clear
        bgnTimePicker.tag = 0

        bgnLabel = UILabel(frame:bgnTimeFrame)
        bgnLabel.text = "  :"
        bgnLabel.setValue(UIColor.white, forKey:"textColor")
        bgnLabel.textAlignment = .center
        bgnLabel.isUserInteractionEnabled = false

        // end hour:Min
        endTimePicker = UIPickerView(frame:endTimeFrame)
        endTimePicker.delegate = self
        endTimePicker.dataSource = self
        endTimePicker.setValue(UIColor.white, forKey:"textColor")
        endTimePicker.backgroundColor = .clear
        endTimePicker.tag = 1

        endLabel = UILabel(frame:endTimeFrame)
        endLabel.text = "  :"
        endLabel.setValue(UIColor.white, forKey:"textColor")
        endLabel.textAlignment = .center
        endLabel.isUserInteractionEnabled = false

        // arrow label between start end

        arrowLabel = UILabel(frame:arrowFrame)
        arrowLabel.text = " ⟶"
        arrowLabel.setValue(UIColor.white, forKey:"textColor")
        arrowLabel.textAlignment = .center
        arrowLabel.isUserInteractionEnabled = false

        bezel.addSubview(arrowLabel)
        bezel.addSubview(bgnLabel)
        bezel.addSubview(endLabel)
        bezel.addSubview(bgnTimePicker)
        bezel.addSubview(endTimePicker)

        // update time picker
        updateBgnTimePicker(animated:false)
        updateEndTimePicker(animated:false)
    }

  
    override func updateFrames(_ size:CGSize) {

        let leftX = CGFloat(treeNode.level-1) * 2 * marginW
        let leftY = marginH

        let bezelX = leftX + leftW + marginW
        let bezelY = marginH / 2
        let bezelH = height - marginH
        let bezelW = size.width - bezelX

        let timeH   = CGFloat(64)
        let timeY   = (height-timeH)/2
        
        let btimeX  = CGFloat(0)
        let timeW  = bezelW/2
        let etimeX  = btimeX + timeW

        leftFrame     = CGRect(x: leftX,   y: leftY,  width: leftW,  height: leftW)
        bgnTimeFrame  = CGRect(x: btimeX,  y: timeY,  width: timeW,  height: timeH)
        endTimeFrame  = CGRect(x: etimeX,  y: timeY,  width: timeW,  height: timeH)
        arrowFrame    = CGRect(x: 0,       y: 0,      width: bezelW, height: bezelH)
        bezelFrame    = CGRect(x: bezelX,  y: bezelY, width: bezelW, height: bezelH)
    }

 
    override func updateViews() {
        
        super.updateViews()

    }

 }

















