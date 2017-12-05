//  Anim+Action.swift

import Foundation

extension Anim {
    
    /**
     User selected next dot - either pause or continue transition between futr and past
     - via: Anim.touchDialPan
     - via: WatchCon.crownDidRotate
     */
    func userDotAction(_ flipTense:Bool = false, dur: TimeInterval = 0.5 ) {
        
        //let animPrev = animNow // for print changes, below
        
        let now  = dots.dotNow
        let prev = dots.dotPrev
        
        func setFanOut  (_ next: Animating) { animNow = next ; fanOutTime = 0 ; fanOutDur   = dur }
        func setFadeOut (_ next: Animating) { animNow = next ; spokeTime  = 0 ; spokeDur    = dur }
        func setFadeIn  (_ next: Animating) { animNow = next ; wheelTime  = 0 ; wheelDur    = dur }
        func setRecSpoke(_ next: Animating) { animNow = next ; finishTime = 0 ; recSpokeDur = dur }


        switch animNow {
            
        case .futrSpoke:    if      now < 0 || flipTense        { setFanOut(.pastFanOut) }
        case .pastSpoke:    if      now > 0 || flipTense        { setFanOut(.futrFanOut) }
            
        case .futrWheel:    if      now < 0 || flipTense        { setFanOut(.pastFanOut) }
        /**/                else if now >= 0.5                  { animNow = .futrPause }
            
        case .pastWheel:    if      now > 0 || flipTense        { setFanOut(.futrFanOut) }
        /**/                else if now <= -0.5                 { animNow = .pastPause }
            
        case .futrFanOut:   if      now < 0 || flipTense        { setFanOut(.pastFanOut) }
        case .pastFanOut:   if      now > 0 || flipTense        { setFanOut(.futrFanOut) }
            
        case .futrPause:    if      now < 0 || flipTense        { setFanOut(.pastFanOut) }
        /**/                else if now >= 0.5 { if prev <  0.5 { setFadeOut(.futrSpoke) }}
        /**/                else               { if prev >= 0.5 { setFadeIn(.futrWheel) }}
            
        case .pastPause:    if      now > 0 || flipTense          { setFanOut(.futrFanOut) }
        /**/                else if now <= -0.5 { if prev >  -0.5 { setFadeOut(.pastSpoke) }}
        /**/                else                { if prev <= -0.5 { setFadeIn(.pastWheel) }}

        case .recSpoke:                                             setRecSpoke(.recSpoke)
        case .recFinish:                                            setRecSpoke(.recFinish)

        case .pastScan, .pastMark:                                  animNow = .pastPause
        case .futrScan, .futrMark:                                  animNow = .futrPause

        case .startup, .shutdown:                                   startupTime  = 0
        }
        actionTime  = Date().timeIntervalSince1970
        //printLog(String(format: "⎚ userDotAction dot Prev,Now: %g,%g  %@⟶%@  tense:%@", prev,now,"\(animPrev)","\(animNow)","\(flipTense)"))
    }
    
    // pause ------------------------------------------

    @discardableResult
    func pauseAnimation() -> Bool { printLog ("⎚ \(#function) animNow:\(animNow)")
        Say.shared.clearAll() //???
        finishTimer.invalidate()
        let wasPausing = (animNow == .futrPause || animNow == .pastPause)

        switch animNow {
        case .recSpoke: break //!! stop recording
        default:
            let index = getDotIndex()
            dots.dotNow = Float(index)
            dots.dotPrev = Float(index)
            animPause = animNow
            animNow = animNow.rawValue > 0 ? .futrPause : .pastPause
        }
        return wasPausing
    }

    func resumeScan() {
        
        switch animPause {
        case .futrPause,
             .futrFanOut,
             .futrWheel,
             .futrSpoke:   animNow = .futrScan

        case .pastPause,
             .pastFanOut,
             .pastSpoke,
             .pastWheel:   animNow = .pastScan

        case .futrMark, .futrScan,
             .pastMark, .pastScan:      break

        case .startup,.shutdown:        break

        case .recSpoke: break //!! stop recording
        case .recFinish: break
        }

         ///??? animNow = animNow.rawValue > 0 ? .futrScan : .pastScan
    }
    
    // Touch --------------------------------------------------

    /**
     User has touched dial
     - via: WatchCon.crownDidRotate
     - via: EventVC^TouchDial.began
     */
    func touchDialDown() {

        finishTimer.invalidate()

        switch animNow {
            
        case .pastScan, .pastMark,
             .futrScan, .futrMark:
            
            let index = getDotIndex()
            dots.startAction(Float(index))
            dayHour.setIndex(index)
            
        default:
            
            dots.startAction(dots.dotNow)
        }
        pauseAnimation()
    }
    
    
    /**
     Animate dial to new time.
     - via: EventTable+Select.(nextMuCell actionTap) -> forceAnim:true
     - via: Scene+Marks.markEvent -> forceAnim:true
     */

    func touchDialGotoTime(_ timeNext: TimeInterval) {

        finishTimer.invalidate()
        dots.selectTime(timeNext) // set +/10.5 for current hour?
        
        animNow = dots.dotNow == 0
            ? dots.dotPrev > 0 ? .futrFanOut : .pastFanOut
            : dots.dotNow  > 0 ? .futrFanOut : .pastFanOut
        
        fanOutDur = 0.25
        fanOutTime = 0
        dots.dotPrev = dots.dotNow
        
        //printLog(String(format: "⎚ \(#function) frame:%.1f dotPrevNow:%.1f,%.1f \(animNow)", sceneFrame, dots.dotPrev, dots.dotNow))
    }

 
    func shutdownAnimation() {  printLog("⎚⎚ \(#function)")
        finishTimer.invalidate()
        dots.selectTime(Date().timeIntervalSince1970)
        dots.dotNow = 0.1
        animNow = .futrPause
        sceneFrame = 0 
        scene.uFrame?.floatValue = (abs(sceneFrame)+0.5)/Float(Anidex.animEnd.rawValue)
        scene.updatePastFutr()

     }


    func gotoRecordSpoke(on:Bool) { printLog("⎚  gotoRecordSpoke(on:\(on))")

        finishTimer.invalidate()
        closures.removeAll()

        if on {
            dots.selectTime(Date().timeIntervalSince1970)
            animNow = .recSpoke
            userDotAction()
        }
        else {
            gotoRecFinish()
        }
    }

    /**
    While scrolling animate dial to new time.
    - via: EventTable+Scroll^scrollViewDidScroll -> forceAnim:false
    */
    func scrollingGotoTime(_ timeNext: TimeInterval, duration:TimeInterval) {
        
        dots.selectTime(timeNext) // set +/10.5 for current hour?
        fanOutToDotNow(duration:duration)
    }

    /**
     scrolling will call many times with the same dot value,
     which can reset animation before it has a chance to start,
     resulting in a long pause until scrolling stops
     so only reset animatinon for a new dot
     */
    func fanOutToDotNow(duration:TimeInterval) {

        if dots.dotPrev != dots.dotNow {
            animNow = dots.dotNow == 0
                ? dots.dotPrev > 0 ? .futrFanOut : .pastFanOut
                : dots.dotNow  > 0 ? .futrFanOut : .pastFanOut

            fanOutDur = duration
            fanOutTime = 0
            //printLog(String(format: "⎚ \(#function) frame:%.1f dotPrevNow:%.1f,%.1f \(animNow)", sceneFrame, dots.dotPrev, dots.dotNow))
        }
    }

    /**
     Set animatino direction of dial animation
     - via: EventTable+PhoneCrown::phoneCrownDeltaRow
     */
    func touchDialClockwise(_ clockwise: Bool) {
        
        dots.dotPrev = dots.dotNow //
        if clockwise != dots.isClockwise {
            //printLog ("\(#function) isClockwise:\(dots.isClockwise) -> \(clockwise)")
            dots.isClockwise = clockwise
        }
    }



}
