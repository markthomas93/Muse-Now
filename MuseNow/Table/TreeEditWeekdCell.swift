import UIKit
import EventKit

class TreeEditWeekdayCell: TreeEditCell {

    var weekdays = [UILabel]()
    var weekFrames = [CGRect]()
    var dayLabels = ["Sun","Mon","Tue","Wed","Thr","Fri","Sat"]

    convenience required init(coder decoder: NSCoder) {
        self.init(coder: decoder)
    }

    convenience init(_ treeNode_: TreeNode!, _ tableVC_:UITableViewController) {
        self.init()
        tableVC = tableVC_
        treeNode = treeNode_
        let width = tableVC.view.frame.size.width
        frame.size = CGSize(width:width, height:height)
        buildViews(width)
    }

    func setLabel(_ label:UILabel!, isOn:Bool) {

        let textColor:UIColor = isOn ? .black     : .white
        let backColor:UIColor = isOn ? .lightGray : cellColor

        label.textColor = textColor
        label.backgroundColor = backColor
    }

    func buildLabel(_ index:Int, _ isOn:Bool) -> UILabel {

        let frame = weekFrames[index]
        let label = UILabel(frame:frame)

        setLabel(label, isOn: isOn)

        label.font = UIFont(name: "Menlo-Bold", size: 14)!
        label.textAlignment = .center
        label.lineBreakMode = .byClipping

        //label.isHighlighted = true
        label.layer.borderWidth = 0.5
        label.layer.borderColor = UIColor.gray.cgColor

        label.text = dayLabels[index]
        return label
    }

    override func buildViews(_ width: CGFloat) {
        
        super.buildViews(width)

        if let node = treeNode as? TreeRoutineItemNode,
            let item = node.routineItem {

            weekdays.removeAll()

            for i in 0 ..< 7 {
                let mask = 1 << (6 - i)
                let isOn = (item.daysOfWeek.rawValue & mask) != 0
                let label = buildLabel(i, isOn)
                weekdays.append(label)
                bezel.addSubview(label)
            }
        }
    }

    override func updateFrames(_ width:CGFloat) {

        let leftX = CGFloat(treeNode.level-1) * 2 * marginW
        let leftY = marginH

        let bezelX = leftX + leftW + marginW
        let bezelY = marginH / 2
        let bezelH = height - marginH
        let bezelW = width - bezelX

        let weekW = ceil(bezelW / 7 * 2) / 2
        var weekX = CGFloat(0)

        cellFrame  = CGRect(x: 0,     y: 0,     width: width, height: height)
        leftFrame  = CGRect(x: leftX, y: leftY, width: leftW, height: leftW)

        weekFrames.removeAll()
        for _ in 0..<7 {

            let wframe = CGRect(x:weekX, y:0, width:weekW, height:bezelH)
            weekX = weekX + weekW
            weekFrames.append(wframe)
        }
        bezelFrame = CGRect(x:bezelX,  y:bezelY, width:bezelW, height:bezelH)
    }

    override func updateViews(_ width:CGFloat) {
        
        updateFrames(width)

        self.frame = cellFrame
        left.frame = leftFrame
        bezel.frame = bezelFrame
        
        // update each label
        for i in 0 ..< 7 {
            let frame = weekFrames[i]
            let day = weekdays[i]
            day.frame = frame
        }
    }

    override func setHighlight(_ highlighting_:Highlighting, animated:Bool = true) {

        if highlighting != highlighting_ {

            var index = 0
            switch highlighting_ {
            case .high,.forceHigh: highlighting = .high ; index = 1 ; isSelected = true
            default:               highlighting = .low  ; index = 0 ; isSelected = false
            }
            let borders     = [headColor.cgColor, UIColor.white.cgColor]
            let backgrounds = [UIColor.black.cgColor, UIColor.white.cgColor]

            if animated {
                animateViews([bezel], borders, backgrounds, index, duration: 0.25)
            }
            else {
                bezel.layer.borderColor    = borders[index]
                bezel.layer.backgroundColor = backgrounds[index]
            }
        }
        else {
            switch highlighting {
            case .high,.forceHigh: isSelected = true
            default:               isSelected = false
            }
        }
    }

    override func touchCell(_ point: CGPoint) {

        (tableVC as? TreeTableVC)?.setTouchedCell(self)
        
        let location = CGPoint(x: point.x - bezelFrame.origin.x, y: point.y)

        for i in 0..<7 {

            if weekFrames[i].contains(location) {

                if  let node = treeNode as? TreeRoutineItemNode,
                    let item = node.routineItem {

                    // flip day optionset
                    let mask = 1 << (6 - i)
                    let dow = item.daysOfWeek.rawValue ^ mask
                    item.daysOfWeek = DaysOfWeek(rawValue:dow)
                    item.updateLabelStrings()

                    // update lable
                    let isOn = (dow & mask) != 0
                    let label = weekdays[i]
                    setLabel(label, isOn: isOn)

                    if let parent = node.parent,
                        let cell = parent.cell as? TreeTimeTitleDaysCell {

                        cell.days.text = item.dowString
                    }
                    break
                }
            }
        }
        treeNode.updateCallback() // refresh dial
    }
 }

















