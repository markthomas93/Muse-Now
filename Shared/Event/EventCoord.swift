//
//  EventCoord.swift
//  MuseNow
//
//  Created by warren on 2/14/18.
//  Copyright © 2018 Muse. All rights reserved.
//

import Foundation
import UIKit

struct Coordinate: Codable {
    var latitude: Double
    var longitude: Double

    init(_ lat:Double,_ lon:Double) {
        latitude = lat
        longitude = lon
    }
}
