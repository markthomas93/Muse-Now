//
//  TreeButtonNode.swift
// muse •
//
//  Created by warren on 6/27/18.
//  Copyright © 2018 Muse. All rights reserved.
//

import Foundation

class TreeButtonNode: TreeNode {

    var alert: String!
    var body: String!
    var anys: [Any]!

    private enum TreeDialColorCodingKeys: String, CodingKey {
        case alert = "alert"
        case body = "body"
    }

    override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: TreeDialColorCodingKeys.self)
        try container.encode(self.alert, forKey: .alert)
        try container.encode(self.body, forKey: .body)
    }

    convenience init(_ title_:String,_ parent_:TreeNode!,_ alert_:String,_ body_:String, _ anys_:[Any]) {

        self.init(title_, parent_, .TreeButtonNode, .titleButton, TreeSetting(true))
        alert = alert_
        body = body_
        anys = anys_
    }

    override func initCell() {

        cell = MenuTitleButton(self)

        #if os(iOS)
        if let cell = cell as? MenuTitleButton {
            cell.butnAct = {  // block collapsing cell from cancelling tour
                cell.infoSection?.blockCancel(duration: 2.0)
                Alert.shared.doAct(self.alert, self.body, self.anys)
            }
        }
        #endif
    }
    
}
