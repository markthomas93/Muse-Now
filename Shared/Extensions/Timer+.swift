//
//  Timer+.swift
//  MuseNow
//
//  Created by warren on 5/17/18.
//  Copyright © 2018 Muse. All rights reserved.
//

import Foundation

extension Timer {
    class func delay(_ delay:TimeInterval,_ fn:@escaping CallVoid) {
        let _ = Timer.scheduledTimer(withTimeInterval: delay, repeats: false, block: {_ in fn()})
    }
}

