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
    var onRatio = Float(1.0)
    var isList = true

    init(_ title_:String,_ item:RoutineItem,_ color_:UInt32) {

        title = title_
        items.append(item)
        color = color_
    }

    func setOnRatio(_ onRatio_:Float) {

        onRatio = onRatio_
        for item in items {
            item.onRatio = onRatio_
        }
    }
}
