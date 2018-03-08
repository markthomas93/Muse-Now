//
//  TourSection.swift
//  MuseNow
//
//  Created by warren on 1/4/18.
//  Copyright © 2018 Muse. All rights reserved.
//

import Foundation
import UIKit

class TourSection {

    var title: String
    var bubbles = [Bubble]()
    var tourSet: TourSet!

    var blockCancelStart = TimeInterval(0) // start time ob
    var blockCancelDuration = TimeInterval(2)


    init(_ title_:String,_ tourSet_:TourSet,_ bubbles_:[Bubble?]) {

        title = title_
        tourSet = tourSet_

        for bubble in bubbles_ {
            if let bubble = bubble {
                bubbles.append(bubble)
            }
        }
        if !tourSet.intersection([.main,.menu,.detail]).isEmpty {
            Tour.shared.tourBubbles.append(contentsOf: bubbles)
        }
    }
    /**
     Block user from canceling a tour section for duration
    */
    func blockCancel(duration:TimeInterval) {
        blockCancelDuration = duration
        blockCancelStart = Date().timeIntervalSinceNow
    }

    /**
     cancel tour section when not blocked
    */
    func cancel() {
        let timeNow = Date().timeIntervalSinceNow
        let deltaTime = timeNow - blockCancelStart
        if deltaTime > blockCancelDuration {
            Tour.shared.cancelSection(self)
        }
    }

}

