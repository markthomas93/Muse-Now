//
//  File.swift
//  MuseNow
//
//  Created by warren on 6/27/18.
//  Copyright © 2018 Muse. All rights reserved.
//

import Foundation


class TreeDialColorNode: TreeNode {

    var dialColor = Float(0)

    private enum TreeDialColorCodingKeys: String, CodingKey {
        case dialColor = "dialColor"
    }
    override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: TreeDialColorCodingKeys.self)
        try container.encode(self.dialColor, forKey: .dialColor)
    }

    convenience init (_ title_:String,_ parent_:TreeNode!) {
        self.init(title_, parent_,.TreeDialColorNode, .titleFader, TreeSetting(false))
        dialColor = Settings.shared.dialColor
    }

    override func initCell() {
        cell = MenuTitleFader(self)
    }

    override func updateCell() {
        if cell == nil {
            initCell()
        }
        if let cell = cell as? MenuTitleFader {
            // intialize fader

            cell.fader?.setValue(Settings.shared.dialColor)

            #if os(iOS)
            // callback when starting fade, so freeze scrolling
            cell.fader?.updateBegan = {
                cell.tableView?.isScrollEnabled = false
                PagesVC.shared.scrollView?.isScrollEnabled = false
            }
            // callback when ending fade, so free scrolling
            cell.fader?.updateEnded = {
                cell.tableView?.isScrollEnabled = true
                PagesVC.shared.scrollView?.isScrollEnabled = true
            }
            #endif
            // callback to set dial color
            let updateFunc: CallFloat = { value in
                Actions.shared.doAction(.dialColor, value: value, isSender: true)
                let phrase = String(format:"%.2f",value)
                Say.shared.updateDialog(nil, .phraseSlider, spoken:phrase, title:phrase, via:#function)
            }

            #if os(iOS)
            cell.fader?.updateFunc = updateFunc // early bound
            #else
            userInfo?["updateFunc"] = updateFunc // late bound
            #endif
        }
    }

}
