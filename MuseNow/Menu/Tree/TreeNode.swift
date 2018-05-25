//
//  TreeNode.swift
//  MuseNow
//
//  Created by warren on 11/18/17.
//  Copyright © 2017 Muse. All rights reserved.
//

import Foundation
import WatchKit

public enum ParentChildOther { case parent, child, other }


class TreeNode: TreeBase {

    convenience init (_ name_:String, _ parent_:TreeBase!,_ type_:TreeNodeType) {
        self.init(name_, parent_, type_, TreeSetting(set:1,member:1))
    }

    override func initNode () {

        level = (parent?.level ?? 0) + 1 

        // iOS is early bound, watchOS is late bound
        #if os(iOS)
            switch nodeType {

            case .title:            cell = MenuTitle(self)
            case .titleButton:      cell = MenuTitleButton(self)
            case .titleFader:       cell = MenuTitleFader(self)
            case .titleMark:        cell = MenuTitleMark(self)
            case .colorTitle:       cell = MenuColorTitle(self)
            case .colorTitleMark:   cell = MenuColorTitleMark(self)

            case .timeTitleDays:    cell = MenuTimeTitleDays(self)
            case .editTime:         cell = MenuEditTime(self)
            case .editTitle:        cell = MenuEditTitle(self)
            case .editWeekday:      cell = MenuEditWeekday(self)
            case .editColor:        cell = MenuEditColor(self)
            case .unknown:          cell = MenuEditColor(self)
            case .none,.some(_):    cell = nil
        }

        #endif
    }
}



