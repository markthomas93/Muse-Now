//
//  TreeEditTimeCell+user.swift
// muse •
//
//  Created by warren on 12/5/17.
//  Copyright © 2017 Muse. All rights reserved.
//

import Foundation

extension MenuEditTime {

    func setTimePicker(_ houri:Int,_ minutei:Int,_ tag:Int) {

        if let node = treeNode as? TreeRoutineItemNode {
            // begin time
            if tag == 0 {
                node.routineItem.bgnMinutes = houri*60 + minutei
                updateEndTimePicker(animated: true)
            }
                // end time
            else {
                let bgnMin = node.routineItem.bgnMinutes
                var endMin = houri*60 + minutei
                if endMin < bgnMin {
                    endMin += 24 * 60
                }
                node.routineItem.durMinutes = endMin - bgnMin
                node.routineItem.updateLabelStrings()
            }
        }
    }

    func updateBgnTimePicker(animated:Bool) {

        if let node = treeNode as? TreeRoutineItemNode {

            let bgnMin = node.routineItem.bgnMinutes
            let bgnHouri = bgnMin / 60
            let bgnMini = (bgnMin  - bgnHouri * 60) / 5

            bgnTimePicker.selectRow(bgnHouri, inComponent: 0, animated: animated)
            bgnTimePicker.selectRow(bgnMini,  inComponent: 1, animated: animated)
        }
    }

    func updateEndTimePicker(animated:Bool) {

        if let node = treeNode as? TreeRoutineItemNode {

            let endMin = node.routineItem.bgnMinutes + node.routineItem.durMinutes
            var endHouri = endMin / 60
            let endMini = (endMin - endHouri * 60) / 5
            endHouri = endHouri % 24

            endTimePicker.selectRow(endHouri, inComponent: 0, animated: animated)
            endTimePicker.selectRow(endMini,  inComponent: 1, animated: animated)
        }
    }
}
