//
//  TreeNode+Level.swift
//  MuseNow
//
//  Created by warren on 5/24/18.
//  Copyright © 2018 Muse. All rights reserved.
//

import Foundation

extension TreeNode {

    @discardableResult func renumber() -> Int {
        depth = 0
        if expanded {
            for child in children {
                child.row = TreeNodes.shared.nextNodes.count
                TreeNodes.shared.nextNodes.append(child)
                depth = max(depth,child.renumber())
            }
        }
        return depth + 1
    }

    func getParentChildOther() -> ParentChildOther {
        if depth == 0, parent?.depth == 1 { return .child }
        else if depth == 1, expanded      { return .parent }
        else                              { return .other }
    }

    /**
     Determine parents ratios of children checked.
     Ratio will determin whether parent has a check, minus or blank
     - blank: n == 0
     - minus: n > 0 and n < 1
     - check: n == 1
     */
    func updateOnRatioFromChildren() {

        if let setting = setting,
            setting.setFrom.contains(.child)  {

            if children.isEmpty {
                return onRatio = setting.isOn ? 1 : 0
            }
            // only count children which have marks
            var markCount = Float(0)
            var isOnCount = Float(0)
            for child in children {
                if let childSetting = child.setting {
                    if childSetting.setFrom == [.ignore] {
                        continue
                    }
                    if childSetting.setFrom.contains(.parent) {
                        switch child.cellType {
                        case .titleMark?,
                             .colorTitleMark?:
                            markCount += 1.0
                            isOnCount += childSetting.isOn ? 1 : 0
                        default: break // ignore non marked child
                        }
                    }
                }
            }
            if markCount > 0 {
                onRatio =  isOnCount/markCount
            }
            else {
                onRatio = setting.isOn ? 1 : 0
            }
            setting.isOn = onRatio > 0 // synch setting with onRatio
        }
    }

    func updateFromParent(_ isParentOn:Bool) {

        if let setting = setting,
            setting.setFrom.contains(.parent),
            isParentOn != setting.isOn {

            let isOn = setting.flipSet()
            onRatio = isOn ? 1.0 : 0.0
            //\\cell?.setMark(onRatio)
            for child in children {
                child.updateFromParent(isOn)
            }
            updateCell()
        }
    }

     func toggle() {
        if let setting = setting {
            let isOn = setting.flipSet()
            updateOn(isOn)
            TreeNodes.shared.syncNode(self)
        }
    }

    func updateOn(_ isOn:Bool) {

        if let setting = setting {
            onRatio = isOn ? 1 : 0
            setting.isOn = isOn // synch setting with onRatio

            for child in children {
                child.updateFromParent(setting.isOn)
            }
             cell?.setMark(onRatio)
            updateCell() //\\

            // update parent
            if let parent = parent {
                parent.updateOnRatioFromChildren()
                parent.cell?.setMark(parent.onRatio)
                parent.updateCell()
            }
        }
    }

}
