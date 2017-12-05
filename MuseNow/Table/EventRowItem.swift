//
//  EventRowItem.swift
//  MuseNow
//
//  Created by warren on 12/4/17.
//  Copyright © 2017 Muse. All rights reserved.
//

import Foundation
import UIKit

class EventRowItem {

    var event: MuEvent!
    var title: String!
    var rowTime = TimeInterval(0)
    var posY = CGFloat(0)

    init(_ event_:MuEvent!,_ posY_:CGFloat) {

        event = event_
        rowTime = event.bgnTime
        title = event.title
        posY = posY_
    }

    init(_ rowTime_: TimeInterval,_ title_: String, _ posY_: CGFloat) {

        event = nil
        rowTime = rowTime_
        title = title_
        posY = posY_
    }

    func getId() -> String {
        if let event = event {
            return event.eventId
        }
        else if let title = title {
            return title
        }
        else {
            print("!!! \(#function) unexpected \(self)")
            return "unknown"
        }
    }
    /**
     when the minute matches, cell may appear above or below
     - hour headers will appear below
     - calendar and reminder events appear below
     - recorded memos will appear above
     */

    func isAfterTime(_ testTime:TimeInterval) -> Bool {
        if let event = event,
            event.type == .memo {
            return rowTime >= testTime + 60
        }
        else {
            return rowTime >= testTime
        }
    }
    func nextFreeY() -> CGFloat {
        if event != nil { return posY + rowHeight }
        else            { return posY + sectionHeight }
    }
}

