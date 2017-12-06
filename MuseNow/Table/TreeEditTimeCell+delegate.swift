//  CalCell.swift


import UIKit
import EventKit

/**
 Picker Delegates for Start and End Time
 */
extension TreeEditTimeCell: UIPickerViewDelegate, UIPickerViewDataSource {

      // delegates ---------------------
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }

    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch component {
        case 0: return hours.count
        case 1: return mins.count
        default: return 1
        }
    }

    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {

        var str = " "
        switch component {
        case 0: str = hours[row]
        case 1: str = mins[row]
        default:  break
        }
        let attributes = [NSAttributedStringKey.foregroundColor:UIColor.white]
        return   NSAttributedString(string: str, attributes: attributes)
    }

    public func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        return 44
    }

    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 44
    }

    public func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int){
        print("\(#function) component:\(component) row:\(row)")

        let isBeginPicker = pickerView == bgnTimePicker

        if let node = treeNode as? TreeRoutineItemNode,
            let item = node.routineItem {

            let mins = item.bgnMinutes + (isBeginPicker ? 0 : item.durMinutes)  // add end time if needed
            var houri = mins/60
            var mini = mins - houri*60

            switch component {
            case 0: houri = row // change hour
            case 1: mini = row*5 // change minutes
            default: return
            }

            if isBeginPicker {
                node.routineItem.bgnMinutes = houri*60 + mini
                updateEndTimePicker(animated: true)
                item.updateLabelStrings()
                if let nodeParent = node.parent,
                    let parentCell = nodeParent.cell as? TreeTimeTitleDaysCell {
                    parentCell.time.text = item.bgnTimeStr
                }
            }
                // end time
            else {
                let bgnMin = node.routineItem.bgnMinutes
                var endMin = houri*60 + mini
                if endMin < bgnMin {
                    endMin += 24 * 60
                }
                node.routineItem.durMinutes = endMin - bgnMin
                node.routineItem.updateLabelStrings()
            }
            treeNode.updateCallback() // refresh dial
        }
    }
 }

