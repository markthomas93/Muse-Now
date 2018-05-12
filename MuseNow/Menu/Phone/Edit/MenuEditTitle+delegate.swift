import UIKit
import EventKit

/**
 Picker Delegates for Editing Text field
 */
extension MenuEditTitle: UITextFieldDelegate {

    // user changes

    func changeParentText(_ changedText:String) {
        if let node = treeNode as? TreeRoutineItemNode,
            let nodeParent = node.parent,
            let parentCell = nodeParent.cell as? MenuTimeTitleDays {

            node.routineItem.title = changedText
            parentCell.title.text = changedText
        }
    }

    @objc func textChanged(_ textChanged:UITextField) {
        if let changedText = textChanged.text {
            textField.text = changedText
            changeParentText(changedText)
        }
    }

    // delegates

    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {

        (TreeNodes.shared.vc as? MenuTableVC)?.setTouchedCell(self)
        
         textField.keyboardAppearance =  UIAccessibilityIsInvertColorsEnabled() ? .default : .dark

        Log ("▭ \(#function)")
        if textField.text != nil {
            textField.text = ""
        }
        return true
    }

    func textFieldDidEndEditing(_ textField: UITextField)  {

        if let parent = treeNode.parent,
            let parentCell = parent.cell {
           (TreeNodes.shared.vc as? MenuTableVC)?.setTouchedCell(parentCell)
        }
        
        Log ("▭ \(#function)")
        textClear.isHidden = true
        if textField.text == nil || textField.text! == "" {
            textField.text = prevText
            changeParentText(prevText)
        }
        else {
            prevText = textField.text ?? prevText
        }
        treeNode.treeCallback?(treeNode)
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
         textField.resignFirstResponder()
        return true
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {

        Log ("▭ \(#function)")
        if let node = treeNode as? TreeRoutineItemNode {
            prevText = node.routineItem.title
            textField.text = prevText
            textClear.isHidden = false
        }
    }
}

