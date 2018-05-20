//
//  WatchCon+Action.swift
//  MuseNow
//
//  Created by warren on 5/14/18.
//  Copyright © 2018 Muse. All rights reserved.
//

import Foundation
import WatchKit

extension WatchCon {
    
    @IBAction func panAction(_ sender: Any) { // on dial

        if let pan = sender as? WKPanGestureRecognizer {

            let pos1 = pan.locationInObject()
            let pos2 = CGPoint(x:pos1.x*2, y:pos1.y*2 )

            Log("👆\(#function) (\(pos2.x),\(pos2.y)) \(pan.state.rawValue)")
            let timestamp = Date().timeIntervalSince1970
            switch pan.state {
            case .began:     touchDial.began(pos2, timestamp)
            case .changed:   touchDial.moved(pos2, timestamp)
            case .ended:     touchDial.ended(pos2, timestamp)
            case .cancelled: touchDial.ended(pos2, timestamp)
            default: break
            }
        }
    }

    // Tap  -------------------------------------
    
    @IBAction func tapAction(_ sender: Any) { Log("👆\(#function)")

        let timeStamp = Date().timeIntervalSince1970
        touchDial?.tapping(timeStamp)
    }

    @IBAction func sliderAction(_ sender: Any) { // on bottom
        panAction(sender)
    }
}
