//
//  ComplicationProvider.swift
//  MuseNow WatchKit Extension
//
//  Created by warren on 10/28/17.
//  Copyright © 2017 Muse. All rights reserved.
//

import Foundation
import ClockKit
import WatchKit

class ComplicationProvider {

    var provider : CLKImageProvider!
    var radians  : CGFloat
    var tint     : UIColor

    init (_ hourDelta:Int) {

        let hour = (Calendar.current as NSCalendar).components([.hour], from: Date()).hour!
        let hourOfs = CGFloat(hour + hourDelta + 12) / 24
        radians = CGFloat.pi * 2 * hourOfs

        let dot = Dots.shared.futr[hourDelta]
        let rgb = dot.rgb
        tint = MuColor.getUIColor(rgb)

        if  let watchCon = WKExtension.shared().rootInterfaceController as? WatchCon,
            let skScene = watchCon.skInterface,
            let scene = skScene.scene as? Scene {

            let comps = scene.complications

            if  comps.count >= 3 {

                let img0 = UIImage(cgImage:comps[0].cgImage())
                let onepiece = img0.rotate(radians: radians)

                let img1 = UIImage(cgImage:comps[1].cgImage())
                let foreground = img1.rotate(radians: radians)

                // hub never rotates
                let background = UIImage(cgImage:comps[2].cgImage())

                provider = CLKImageProvider(onePieceImage: onepiece,
                                            twoPieceImageBackground: background,
                                            twoPieceImageForeground: foreground)
                provider?.tintColor = tint
            }
            else if comps.count > 0 {

                let img0 = UIImage(cgImage:comps[0].cgImage())
                let onepiece = img0.rotate(radians: radians)
                provider = CLKImageProvider(onePieceImage: onepiece)
                provider?.tintColor = tint
            }
        }
    }
    func changed(_ hourDelta: Int) -> Bool {

        let hour = (Calendar.current as NSCalendar).components([.hour], from: Date()).hour!
        let hourOfs = CGFloat(hour + hourDelta + 12) / 24
        let testRadians = CGFloat.pi * 2 * hourOfs
        if radians != testRadians { return true }

        let rgb = Dots.shared.futr[hourDelta].rgb
        let testTint = MuColor.getUIColor(rgb)
        if tint != testTint { return true }
        return false
    }
    func unchanged(_ hourDelta: Int) -> Bool {
        return !changed(hourDelta)
    }
}
