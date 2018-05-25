//
//  RoutineCategory.swift
//  MuseNow
//
//  Created by warren on 3/18/18.
//  Copyright © 2018 Muse. All rights reserved.
//

import Foundation

class RoutineCategory: Codable {

    static var nextId = 0
    static func getNextId() -> Int { nextId += 1 ; return nextId }

    var id    =  0
    var title =  ""
    var items =  [RoutineItem]()
    var color = UInt32(0x888888)
    var onRatio = Float(1.0)
    var isList = true

    init(_ title_:String,_ item:RoutineItem,_ color_:UInt32) {

        initRoutineCategory(title_, [item], color_, RoutineItem.getNextId())
    }

    func initRoutineCategory(_ title_:String,_ items_:[RoutineItem],_ color_:UInt32,_ id_:Int) {

        title = title_
        items = items_
        color = color_
        id = id_
    }

    func setOnRatio(_ onRatio_:Float) {

        onRatio = onRatio_
        for item in items {
            item.onRatio = onRatio_
        }
    }
 }
