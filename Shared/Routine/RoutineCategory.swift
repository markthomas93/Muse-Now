//
//  RoutineCategory.swift
//  MuseNow
//
//  Created by warren on 3/18/18.
//  Copyright © 2018 Muse. All rights reserved.
//

import Foundation

class RoutineCategory: Codable {

    var title =  ""
    var items =  [RoutineItem]()
    var color = UInt32(0x888888)
    var isOn = true

    init(_ title_:String,_ item:RoutineItem,_ color_:UInt32) {

        initRoutineCategory(title_, [item], color_)
    }

    func initRoutineCategory(_ title_:String,_ items_:[RoutineItem],_ color_:UInt32) {

        title = title_
        items = items_
        color = color_
    }

}
