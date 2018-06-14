//  Dot+Mark.swift
//  Created by warren on 5/18/18.
//  Copyright © 2018 Muse. All rights reserved.

import Foundation

extension Dot {

    func hasMark() -> Bool {
        for event in events {
            if event.mark && startsThisHour(event) {
                return true
            }
        }
        return false
    }

    func getMark(_ i: Int) -> Bool {
        let event = events[i]
        if event.mark && startsThisHour(event) {
            eventi = i
            return true
        }
        return false
    }

    func foundVia(_ fun:String,_ dotIndex: Int,  _ index:Int,_ note:String = "") -> MuEvent! {
        eventi = index
        let event = events[index]
        Log("⚇ \(fun) dotIndex:\(dotIndex) eventi:\(eventi) \(note)")
        return event
    }

    /**
     timeEvent is constantly shifting,
     moreover adding memo should appear before current time,
     so resort array if needed.
     */
    func updatedTime() -> MuEvent! {
        if !events.isEmpty {
            if events.count == 1 {
                return events.first
            }
            // only sorting events for this hour, so trival performance hit
            events.sort { "\($0.bgnTime)"+$0.eventId < "\($1.bgnTime)"+$1.eventId }
            for event in events {
                if event.type == .time {
                    return event
                }
            }
        }
        return nil
    }

    /**
     Get the first mark that starts on this hour.
     When the hour is 0, then start on the time event.
     */
    func getFirstMark(_ dotIndex:Int, _ isClockwise: Bool) -> MuEvent! {

        if events.count > 0 {
            // at current hour, search for a special time event and start from there
            if dotIndex == 0 {
                return updatedTime()
            }
            if isClockwise {
                for i in 0 ..< events.count {
                    if getMark(i) {
                        return foundVia(#function, dotIndex, i)
                    }
                }
            }
            else { // counter-clockwise 
                eventi = events.count - 1
                for i in (0 ..< events.count).reversed() {
                    if getMark(i) {
                         return foundVia(#function, dotIndex, i)
                    }
                }
            }
        }
        return nil
    }

    /**
    get next mark that starts on this hour
    */
    func getNextMark(_ dotIndex:Int, _ isClockwise: Bool) -> MuEvent! {

        if events.count > 0 {
            if isClockwise {
                if eventi < events.count-1 {
                    for i in eventi+1 ..< events.count {
                        if getMark(i) {
                            return foundVia(#function, dotIndex, i)
                        }
                    }
                }
            }
            else /* counter-clockwise */ {
                if eventi > 0 {
                    for i in (0 ... eventi-1).reversed() {
                        if getMark(i) {
                            return foundVia(#function, dotIndex, i)
                        }
                    }
                }
            }
        }
        return nil
    }


}
