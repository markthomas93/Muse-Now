//
//  TourSet.swift
//  MuseNow
//
//  Created by warren on 5/14/18.
//  Copyright © 2018 Muse. All rights reserved.
//

import Foundation

struct TourSet: OptionSet {
    let rawValue: Int
    static let intro    = TourSet(rawValue: 1 << 0) // 1
    static let main     = TourSet(rawValue: 1 << 1) // 2
    static let menu     = TourSet(rawValue: 1 << 2) // 4
    static let info     = TourSet(rawValue: 1 << 3) // 8
    static let detail   = TourSet(rawValue: 1 << 4) // 16
    static let buy      = TourSet(rawValue: 1 << 5) // 32
    static let beta     = TourSet(rawValue: 1 << 6) // 64
    //static let size = 7
}
