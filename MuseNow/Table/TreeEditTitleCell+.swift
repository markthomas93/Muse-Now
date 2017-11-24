import UIKit
import EventKit

/**
 Picker Delegates for Editing Text field
 */
extension TreeEditTitleCell: UITextFieldDelegate {

    // user changes

    func changeParentText(_ changedText:String) {
        if let node = treeNode as? TreeRoutineItemNode,
            let nodeParent = node.parent,
            let parentCell = nodeParent.cell as? TreeTimeTitleDaysCell {

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
        printLog ("▭ \(#function)")
        if textField.text != nil {
            textField.text = ""
        }
        return true
    }

    func textFieldDidEndEditing(_ textField: UITextField)  {

        printLog ("▭ \(#function)")
        textClear.isHidden = true
        if textField.text == nil || textField.text! == "" {
            textField.text = prevText
            changeParentText(prevText)
        }
        else {
            
            prevText = textField.text ?? prevText
            //??? searchDelegate.searchTextAction(textField.text!)
        }
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
         textField.resignFirstResponder()
        if  let node = treeNode as? TreeRoutineItemNode,
            let nodeParent = node.parent,
            let parentCell = nodeParent.cell as? TreeTimeTitleDaysCell {
                parentCell.touchCell(CGPoint.zero)
        }
        return true
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {

        printLog ("▭ \(#function)")
        if let node = treeNode as? TreeRoutineItemNode {
            prevText = node.routineItem.title
            textField.text = prevText
            textClear.isHidden = false
        }
    }
}

