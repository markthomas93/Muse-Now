//
//  Fader.swift
// muse • WatchKit Extension
//
//  Created by warren on 5/9/18.
//  Copyright © 2018 Muse. All rights reserved.
//

import Foundation

class Fader {

    var value = Float(0.5)
    var updateFunc: CallFloat?
    var updateBegan: CallVoid?
    var updateEnded: CallVoid?

    func setValue(_ value_:Float) {
        value = value_
        //thumb.center.x = thumbR + 2*borderWidth + runway * CGFloat(value)
    }
}
