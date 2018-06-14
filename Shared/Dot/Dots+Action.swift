import UIKit

extension Dots {
    

    /**
     User toggled Mark
     */
    func markDot(_ dot:Dot,_ event:MuEvent, _ isOn:Bool, gotoEvent: Bool = false) {

        dot.setMark(isOn, event)
        dot.makeRgb()
        Actions.shared.doAction(.updateEvent, value: isOn ? 1 : 0, event, isSender: true)
        Haptic.play(.success)
    }

    /**
     User twiddling face of screen dial, fast or slow
     - via: Scene.touchDialPan
     */
    func updateViaPan(_ degree: Double) {
        
        dayHour.nextHour(Int(degree / 15.0))
        let panIndex = dayHour.getIndex()
        dotPrev = dotNow
        dotNow = Float(panIndex)
    }
    /**
     User twiddling face of screen dial, slowly
     - via: Scene.touchDialPan
     */
    func updateFeedback(_ event: MuEvent!, _ isClockwise_:Bool,_ isFuture:Bool,_ isSlow: Bool,_ isNewDay: Bool,_ flipFuture: Bool) {

        feedbackTimer.invalidate()

        isClockwise = isClockwise_
        let doti = Int(dotNow)
        let dot = getDot(doti)

        // slow twiddle may annouce individual events
        if isSlow {
            // has event that stated that hour
            if dot.elapse0 < 60 {

                if let event = dot.getFirstEventForThisHour(isClockwise, dotPrev) {

                    Haptic.play(.click)
                    // wait for 1/4 second linger on that hour
                    feedbackTimer = Timer.scheduledTimer(withTimeInterval: 0.25, repeats:false, block: { _ in
                        Say.shared.sayDotEvent(event, isTouching: true)
                    })
                    return
                }
            }
        }
        if isNewDay {
            let txt  = dayHour.getDowSpeak()
            Say.shared.updateDialog(event, .phraseDayOfWeek, spoken:txt, title:txt, via:#function)
        }
        else if flipFuture {
            Say.shared.sayFuturePast(isFuture)

        }
    }
    
    // Scene Touch -----------------------

     /// - via: Scene.touchDialDow
    func startAction(_ dotStart: Float) {
        
        if Int(dotNow) != Int(dotStart) {
            getDot(Int(dotStart)).resetIndex()
        }
        dotNow = dotStart
        //Log (String(format: "⚇ \(#function) dotNow:%.1f  isClockise:\(isClockwise)",dotNow), terminator:" ")
    }


}
