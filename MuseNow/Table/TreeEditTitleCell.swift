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

    convenience init(_ treeNode_: TreeNode!, _ width: CGFloat) {
        
        self.init()
        treeNode = treeNode_
        frame.size = CGSize(width: width, height: height)
        buildViews(frame.size)
    }

    override func buildViews(_ size: CGSize) {
        
        super.buildViews(size)

        textField = UITextField(frame:textFrame)
        textField.delegate = self
        textField.backgroundColor = .clear
        textField.textColor = .white
        textField.tintColor = .white
        textField.font = UIFont(name: "Helvetica Neue", size: 32)!
        textField.adjustsFontSizeToFitWidth = true
        textField.minimumFontSize = 16
        textField.textAlignment = .center
        textField.clearButtonMode = .whileEditing
        textField.addTarget(self, action: #selector(textChanged), for: .editingChanged)
        textField.keyboardAppearance = UIAccessibilityIsInvertColorsEnabled() ? .default : .dark
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

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: NSNotification.Name.UIKeyboardWillShow,
            object: nil
        )
    }

    @objc func keyboardWillShow(_ notification: Notification) {
        if let frameVal: NSValue = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue {
            let height = frameVal.cgRectValue.size.height
            printLog ("▭ \(#function) height:\(height))")
        }
    }

    override func updateFrames(_ size:CGSize) {

        let leftX = CGFloat(treeNode.level-2) * 2 * marginW
        let leftY = marginH

        let bezelX = leftX + leftW + marginW
        let bezelY = marginH / 2
        let bezelH = height - marginH
        let bezelW = size.width - bezelX

        let clearH = CGFloat(22)
        let clearX = bezelW - clearH - marginW
        let clearY = (bezelH-clearH)/2

        leftFrame     = CGRect(x: leftX,   y: leftY,  width: leftW,  height: leftW)
        textFrame     = CGRect(x: 0,       y: 0,      width: bezelW, height: bezelH)
        clearFrame    = CGRect(x: clearX,  y: clearY, width: clearH, height: clearH)
        bezelFrame    = CGRect(x: bezelX,  y: bezelY, width: bezelW, height: bezelH)
    }

    override func updateViews() {
        
        super.updateViews()

    }

 }

















