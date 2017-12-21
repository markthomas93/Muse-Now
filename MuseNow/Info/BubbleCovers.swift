//
//  File.swift
//  MuseNow
//
//  Created by warren on 12/20/17.
//  Copyright © 2017 Muse. All rights reserved.
//

import Foundation
import UIKit

/**
 More than one Bubble may animate in sequence
 over the same covers that darken the backgroud.
 So, manage handoff between bubbles.
 */

class BubbleCovers {

    static var shared = BubbleCovers()
    let coverAlpha = CGFloat(0.70)  // alpha for covers which darken background
    var covers = [UIView]()         // views in which to darken while showing bubble

    func makeCovers(_ poi:TourPoi) {

        if canFadeIn(poi) {

            covers.removeAll()

            for underView in poi.covering {

                let cover = UIView(frame:underView.frame)
                cover.frame.origin = .zero
                cover.backgroundColor = .black
                cover.alpha = 0.0
                cover.isUserInteractionEnabled = false

                covers.append(cover)
                underView.addSubview(cover)
            }
        }
    }

    func canFadeOut(_ poi:TourPoi) -> Bool {

        if poi.options.contains(.nowait) {
            return false
        }
        if poi.nextPoi == nil {
            return true
        }
        if poi.nextPoi.options.contains(.overlay) {
            return false
        }
        return true
    }

    
     // bring parent to front if not a continuation of a previous nowait
    func canFadeIn(_ poi:TourPoi) -> Bool {

        if poi.options.contains(.overlay) {
            return false
        }
        if poi.prevPoi == nil {
            return true
        }
        if poi.prevPoi.options.contains(.nowait) {
            return false
        }
        if poi.options.contains(.nowait) {
            return true
        }
        return true
    }

    func fadeIn(_ poi:TourPoi) {
        if canFadeIn(poi) {
            for cover in self.covers {
                cover.alpha = self.coverAlpha
            }
        }
    }

    func fadeOut(_ poi:TourPoi) {
        if canFadeOut(poi) {
            for cover in self.covers {
                cover.alpha = 0.0
            }
        }
    }

    func removeFromSuper(_ poi:TourPoi) {
        if canFadeOut(poi) {
            for cover in self.covers {
                cover.removeFromSuperview()
            }
        }
    }
}
