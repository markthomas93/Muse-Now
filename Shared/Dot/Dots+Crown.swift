//  Dots+Crown.swift
//  Created by warren on 9/28/17.
//  Copyright © 2017 Muse. All rights reserved.

import Foundation

extension Dots {


    /**
     Get next dotNow base on delta's direction.

     Events for the current hour may span in the past or future,
     with the following series:

     `dotNow [-168 ... -1, -.5, -0, +0, +.5, +1 ... +168]`, where:

     - +/- 0.0 shows fanOut for future/past week
     - +0.5 shows future events for current hour
     - -0.5 shows past events for current hour

     */
    private func getNextDot(_ delta:Float) -> Bool {

        switch dotNow {
        case   0.5: dotNow = delta > 0 ?  1.0 :    0.0
        case  -0.5: dotNow = delta < 0 ? -1.0 :    0.0
        case  -1.0: dotNow = delta > 0 ? -0.5 :   -2.0
        case   1.0: dotNow = delta < 0 ?  0.5 :    2.0
        case   167: dotNow = delta > 0 ?  0.0 :  166.0
        case  -167: dotNow = delta < 0 ?  0.0 : -166.0
        default:    dotNow += delta
        if      dotNow >  167 { dotNow = 0 }
        else if dotNow < -167 { dotNow = 0 }
        }
        return dotNow != 0
    }


    /**

     Skip to next event
     - via: WatchCon.crownDidRotate
     - returns: true when flipping tense between past and futr

     - note:

     upon start of clio, twist crown away from you

     a) "future" wheel, after, 1 second
     b) progress forward to first event, pause, and announce

     0) "begins"
     1) in 0...90 minutes is <event title> at <time>
     2) in 2..18 hours is <event title> at <time>
     3) tomorrow is <event title> at <time>
     4) on (this|next) <dow> is <event title> at <time>

     c) progress to next event, pause, and announce:

     1) at <time> is <event title>
     2) at <time> is <event title>
     3) tommorrow at <time> is <event title>
     4) on (this|next) <dow> at <time> is <event title>
     */

    func crownNextEvent (_ delta: Float, _ inFuture: Bool) {

        //var nextFuture = inFuture
        Haptic.play(.click)
        isClockwise = delta > 0

        func logCrown(_ optional:String = "" ) {
            Log("⊛ crownNextEvent(\(delta),\(inFuture ? "futr" : "past")) dot Prev ➛ Now: \(dotPrev) ➛ \(dotNow) \(optional)")
        }

        func foundEvent(_ event:MuEvent) {

            dotEvent = event

            Say.shared.cancelSpeech()

            if event.type == .time {
                dotNow = 0
                //Anim.shared.userDotAction(/*flipTense*/false, dur:0.5)
                 Anim.shared.fanOutToDotNow(duration:0.25)
                Say.shared.sayCurrentTime(event,/* isTouching */ true)
            }
            else {
                let timeNow = Date().timeIntervalSince1970
                if  event.bgnTime < timeNow && inFuture ||
                    event.bgnTime > timeNow && !inFuture {
                    Anim.shared.userDotAction(/*flipTense*/true, dur:0.5)
                }
                else {
                    Anim.shared.fanOutToDotNow(duration:0.25)
                }
                Say.shared.sayDotEvent(event, isTouching: true, via:#function)
                Actions.shared.sendAction(.gotoEvent, event, event.bgnTime)
            }
            return logCrown(event.title)
        }

        // Begin ---------------------
        dotPrev = dotNow

        if dotEvent?.type == .time {
            if inFuture != isClockwise {
                Anim.shared.userDotAction(/*flipTense*/true, dur:0.5)
                Say.shared.sayCurrentTime(dotEvent,/* isTouching */ true)
                return logCrown("time")
            }
        }

        // get next event for this hour
        if let event = getDot(Int(dotNow)).getNextEventForThisHour(isClockwise, dotPrev) {

            return foundEvent(event)
        }
        else {
            while getNextDot(delta) {
                if let event =  getDot(Int(dotNow)).getFirstEventForThisHour(isClockwise, dotPrev) {

                    return foundEvent(event)
                }
            }
            if dotNow == 0 {
                return logCrown("done")
            }
        }
    }

}
