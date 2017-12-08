import UIKit
import EventKit

class TreeEditTitleCell: TreeEditCell {

    var textField: UITextField!
    var textFrame = CGRect.zero
    var prevText = ""

    var textClear: UIImageView!
    var clearFrame = CGRect.zero

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

    override func buildViews(_ width:CGFloat) {
        
        super.buildViews(width)

        textField = UITextField(frame:textFrame)
        textField.delegate = self
        textField.backgroundColor = cellColor
        textField.textColor = .white
        textField.tintColor = .white
        textField.font = UIFont(name: "Helvetica Neue", size: 32)!
        textField.adjustsFontSizeToFitWidth = true
        textField.minimumFontSize = 16
        textField.textAlignment = .center
        textField.clearButtonMode = .whileEditing
        textField.addTarget(self, action: #selector(textChanged), for: .editingChanged)
        textField.keyboardAppearance =  UIAccessibilityIsInvertColorsEnabled() ? .default : .dark
        textField.autocorrectionType = .no

        // text clear button inside bezel
        textClear = UIImageView(frame:clearFrame)
        textClear.image = UIImage(named: "Icon-X-plus.png")
        textClear.isUserInteractionEnabled = false
        textClear.isHidden = true

        if let node = treeNode as? TreeRoutineItemNode {
            prevText = node.routineItem.title
            textField.text = prevText
        }

        bezel.addSubview(textField)
        bezel.addSubview(textClear)

     }


     override func updateFrames(_ width:CGFloat) {

        let leftX = CGFloat(treeNode.level-1) * 2 * marginW
        let leftY = marginH

        let bezelX = leftX + leftW + marginW
        let bezelY = marginH / 2
        let bezelH = height - marginH
        let bezelW = width - bezelX

        let clearH = CGFloat(22)
        let clearX = bezelW - clearH - marginW
        let clearY = (bezelH-clearH)/2

        cellFrame  = CGRect(x: 0,       y: 0,      width: width,  height: height)
        leftFrame  = CGRect(x: leftX,   y: leftY,  width: leftW,  height: leftW)
        textFrame  = CGRect(x: 0,       y: 0,      width: bezelW, height: bezelH)
        clearFrame = CGRect(x: clearX,  y: clearY, width: clearH, height: clearH)
        bezelFrame = CGRect(x: bezelX,  y: bezelY, width: bezelW, height: bezelH)
    }

    override func updateViews(_ width:CGFloat) {
        
        updateFrames(width)

        self.frame = cellFrame
        left.frame = leftFrame
        textField.frame = textFrame
        textClear.frame = clearFrame
        bezel.frame = bezelFrame

    }

  }

















