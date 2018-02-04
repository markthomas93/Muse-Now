//
//  BubbleItem.swift
//  MuseNow
//
//  Created by warren on 12/30/17.
//  Copyright © 2017 Muse. All rights reserved.
//

import Foundation
import UIKit

typealias CallWait = (_ bubbleBase: BubbleBase,_ finished: @escaping CallVoid)->()
/**
 Each bubble may have a series of items to display withing itself
 */
class BubbleItem {

    var str: String!                 // either text for bubble or filename
    var duration: TimeInterval
    var callWait: CallWait! // buildup before displaying bubble

    init(_ str_:String,_ duration_:TimeInterval,_ callWait_:CallWait! = nil) {
        str = str_
        duration = duration_
        callWait = callWait_
    }
}

