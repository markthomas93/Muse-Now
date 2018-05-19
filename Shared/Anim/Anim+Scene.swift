//  Anim+Scene.swift

import Foundation

extension Anim {

    func getDotIndex() -> Int {

        let framei = abs(floor(sceneFrame))
        if  framei <= spokeFan ||
            framei >  sceneHours {
            return 0
        }
        else if sceneFrame < 0 {
            return Int(min(0,sceneFrame + spokeFan))
        }
        else {
            return Int(max(0,sceneFrame - spokeFan))
        }
    }
    
    func dotFrame(_ dotNow: Float) -> Float {
        
        if abs(dotNow) >= Float(dots.maxDots) { return 0    }
        else if dotNow <= -0.5 { return trunc(dotNow) - spokeFan }
        else if dotNow >=  0.5 { return trunc(dotNow) + spokeFan }
            
        else if animNow.rawValue > 0 { return  spokeWheel }
        else                         { return -spokeWheel }
    }
    
    // frame update --------------------------------------------------

    func pausing() {

        Closures.shared.execClosures()  // housekeeping during pause in animation

        switch animNow {
        case .futrPause:    sceneFrame = dots.dotNow >=  0.5 ? trunc(dots.dotNow) + spokeFan :  spokeWheel
        case .pastPause:    sceneFrame = dots.dotNow <= -0.5 ? trunc(dots.dotNow) - spokeFan : -spokeWheel
        default:            sceneFrame = dotFrame(dots.dotNow)
        }
    }


    /**
     Increment sceneFrame and reset to zero when reaching the end of sequence
     */
    func scanning() {

        sceneFrame += dots.isClockwise ?  1 : -1

        // user manually changed current dotNow
        if lastFrame * sceneFrame < 0 {
            say.sayFuturePast(animNow.rawValue > 0)
        }
            ///  approaching now, so going in opposite direction, where past is scanning clockwise or futr is scanning counterclockwise
        else if abs(sceneFrame) <= spokeFan {
            if abs(sceneFrame) < 1 {
                if animNow.rawValue > 0 {
                    dots.isClockwise = true
                }
                else {
                    dots.isClockwise = false
                    animNow = .pastPause
                }
                //animNow = animNow.rawValue > 0 ? .futrPause : .pastPause
                dayHour.setIndex(0)
                dots.dotNow = 0
            }
            else if // if crossing the rubicon, then clear out title
                abs(lastFrame) > spokeFan {
                
                say.updateDialog(nil, .phraseBlank, spoken: "", title: "", via:#function)
            }
        }
            // finish animation
        else if abs(sceneFrame) >= Anidex.animEnd.rawValue {
            //??? Closures.shared.execClosures()
            gotoStartupAnim()
        }
             // animNow over hour dots, so pause for any marks
        else if
            abs(sceneFrame) >= Anidex.spokeFan.rawValue,
            abs(sceneFrame) <= Anidex.eachHour.rawValue {
            if let event = dots.sayFirstMark(getDotIndex()) {
                table?.scrollSceneEvent(event) // only on phone, not watch
                animNow = animNow.rawValue > 0 ? .futrMark : .pastMark
            }
        }
    }

    /**
     After scanning says first mark, either
     1) say next marked dot for that hour or
     2) resume scanning animation
     */
    func marking() {

        if say.isSaying {
            Closures.shared.execClosures() // housekeeping during pause in animation
        }
        else if let event = dots.sayNextMark(getDotIndex()) {
            table?.scrollSceneEvent(event) // only on phone, not watch
            animNow = animNow.rawValue > 0 ? .futrMark : .pastMark
        }
        else {
            animNow = animNow.rawValue > 0 ? .futrScan : .pastScan
        }
    }
    
    /**
     Gradually fade in the whole wheel to see summary of whole week,
     when user selects current hour (via pan or crown).
     Fade is from spokeFan -> spokeWheel, either:

     - ( 38 ->  37) or
     - (-38 -> -37)
     */
    func wheelFade() {

        if wheelTime == 0 {

            wheelTime = timeNow
            //let prevSceneFrame = sceneFrame // for Log
            sceneFrame = Float(animNow.rawValue > 0 ?  spokeFan : -spokeFan)
            //Log("⚆ \(#function)   sceneFrame:\(prevSceneFrame) -> \(sceneFrame) ")
            return
        }
        else {

            let wheelElapsed = timeNow - wheelTime
            let wheelRatio = Float(min(1,wheelElapsed/wheelDur))
            sceneFrame = sceneFrame > 0
                ?  spokeFan - wheelRatio
                : -spokeFan + wheelRatio
            //print (String(format:" %.1f",sceneFrame), terminator:"")
            if wheelRatio >= 1 {
                //print (":", terminator:"")
                animNow = sceneFrame > 0 ? .futrPause : .pastPause
            }
       }
    }
    
    /**
     While recording:
     1) begin: Animate from current position to spoke up
     2) loop: through spoke up-down on a one-second loop
     */
    func recSpokeUpDn() {

        if finishTime == 0 {
            finishTime = Date.timeIntervalSinceReferenceDate
            finishFrame = sceneFrame
            scene.uPal?.textureValue = scene.recPalTex
        }

        let elapsedTime = Date.timeIntervalSinceReferenceDate - finishTime
        let elapseRatio = Float(elapsedTime/recSpokeDur)
        let invertRatio = 1.0 - min(1,elapseRatio)

        //Log("⚆ elapse:\(elapseRatio), invert:\(invertRatio) current:\(timeNow) finishTime:\(finishTime)")

        if elapseRatio <= 1.0 {

            let spokeUp = Anidex.spokeUp.rawValue
            let deltaFrame = finishFrame - spokeUp
            sceneFrame = invertRatio * deltaFrame + spokeUp

            let deltaFade = recSpokeFade - 0.5
            let fade = invertRatio * deltaFade + 0.5
            scene.uFade?.floatValue = fade
            Log("⚆ fade:\(fade)")
        }
        else {
            if elapsedTime < 2.0 {
                scene.uFade?.floatValue = 0.5
            }
            var mod = 2.0
            let halfTime = (elapsedTime-recSpokeDur)/2
            let halfMod = Float(modf(halfTime, &mod))
            let invertMod = 1.0 - halfMod
            sceneFrame = invertMod * Anidex.spokeUp.rawValue
        }
    }

    /**
     When user moves from current hour to further along in same direction
     gradually fade out wheel to see a single spoke, in two parts
     1) fade out for firs half of spokeDur duration
     2) animate to current spoke position for remaing spokeDur duration
     */
    func spokeFade() {
        
        if spokeTime==0 {

            // if in middle of spokeIn, then back out, otherwise start from beginning
            let spokeInElapsed = timeNow - wheelTime
            if spokeInElapsed >= wheelDur {
                spokeTime = timeNow
            }
            else {
                let spokeInRatio = spokeInElapsed/wheelDur
                let elapseRatio = (1-spokeInRatio)/2 // only 1st half of fadeOut actually fades
                let spokeOutElapsed = spokeDur * elapseRatio
                spokeTime = timeNow - spokeOutElapsed
            }
        }
        else {
            
            let elapsedTime = timeNow - spokeTime
            let elapseRatio = Float(min(1,elapsedTime/spokeDur))
            
            if elapseRatio < 0.5 {
                
                sceneFrame = sceneFrame > 0
                    ?  spokeWheel + elapseRatio*2
                    : -spokeWheel - elapseRatio*2
                
                 //Log(String(format:"⚆ %.2f,%.1f",elapseRatio,sceneFrame))
            }
            else if elapseRatio >= 1 {
                animNow = animNow.rawValue > 0 ? .futrPause : .pastPause
                pausing()
                 //Log(String(format:"⚆ %.2f,%.1f",elapseRatio,sceneFrame))
            }
            else {
                let frameElapsed = min(1.0,timeNow - timePrev)
                let fps = Float(1/max(1/120.0,frameElapsed))
                let timeRemain = Float(spokeDur - elapsedTime)
                animOut(timeRemain, fps)
                //Log(String(format:"⚆ %.2f,%.1f",elapseRatio,sceneFrame))
            }
        }
    }
    
    /**
     Both futr and past share the same false color texture,
     which flips horizontally and indexes into different palettes.
     So anim may bounce:
     ```
     spokeUp...spokeFan
     -37...-14,14...37
     ```
     Meanwhile, during the transition, user may continue to new dotNow
     So, animation has to keep track of a moving destination.

     FanOut lasts for fanDur (.25) seconds
     */
    func fanOut () {
        if fanOutTime==0 {
            fanOutTime = timeNow // move this up after debug
            return
        }
        else {
            //animElasped(fanOutTime, fanOutDur)

            let frameElapsed = min(1.0,timeNow - timePrev)
            let timeElapsed = timeNow - fanOutTime
            let fps = Float(1/max(1/120.0,frameElapsed))
            let timeRemain = Float(fanOutDur - timeElapsed)

            if timeRemain < 1.0/fps {
                //print ("⚆", terminator:"")
                animNow = animNow.rawValue > 0 ? .futrPause : .pastPause
                pausing()
            }
            else {
                animOut(timeRemain, fps)
            }
        }
    }

    /**
     Animate skipping spoke-up-down part of palette that is used for recording.

     - parameter timeRemain: amount of time remaining for animation
     - parameter fps: frames pers second

     Compare sceneFrame to nextFrame (prev to next):

     prev < 0, next > 0 : spokeUp - prev + next - spokeUp
     prev > 0, next < 0 : prev - spokeUp + next - spokeUp
     prev < 0, next < 0 : next - prev
     prev > 0, next > 0 : next - prev

     */
    func animOut(_ timeRemain: Float, _ fps: Float) {

        let nextFrame = dotFrame(dots.dotNow)
        let sceneGap = 2*Anidex.spokeUp.rawValue // gap for spoke down-up anim, when switching past/futr
        
        let distance = nextFrame - sceneFrame
        
        let increment = distance/timeRemain/fps
        if sceneFrame < 0 && (sceneFrame + increment > -Anidex.spokeUp.rawValue) {
            sceneFrame = sceneFrame + increment + sceneGap
            scene.updateSprite(xScale:1.0)
            say.sayFuturePast(/*isFuture*/true)
            scene.updatePastFutr()
        }
        else if sceneFrame > 0 && (sceneFrame + increment < Anidex.spokeUp.rawValue) {
            sceneFrame = sceneFrame + increment - sceneGap
            scene.updateSprite(xScale: -1.0)
            say.sayFuturePast(/*isFuture*/false)
            scene.updatePastFutr()
        }
        else {
            sceneFrame += increment
        }
         //Log(String(format:"⚆ animOut %.1f ➛ %.1f xScale:%.0f dotNow:%.1f (%.1f / %.2f / %.1f) -> %.1f", sceneFrame,nextFrame,xScale,dots.dotNow, distance,timeRemain,fps, increment))
    }
    
     func recFinishAnim() {  Log("⚆ \(#function) sceneFrame:\(sceneFrame))")

        if finishTime == 0 {
            finishTime = timeNow
        }
        let elapsedTime = timeNow - finishTime
        let elapseRatio = Float(elapsedTime/recSpokeDur)

        if elapseRatio <= 1.0 {

            let firstSpoke = Anidex.eachHour.rawValue
            let deltaSpoke = firstSpoke - finishFrame

            sceneFrame = elapseRatio * deltaSpoke + finishFrame

            //let deltaFade = recSpokeFade - 0.5
            //let fade = elapseRatio * deltaFade + 0.5
            //... scene.uFade?.floatValue = fade
            //Log("⚆. fade:\(fade)")
        }
        else {
            //scene.uFade?.floatValue = recSpokeFade
            gotoStartupAnim()
        }
    }

    func shutdownAnim() { Log("⚆ \(#function)   sceneFrame:\(sceneFrame) ")
    }

    func gotoStartupAnim() {

        startupTime = 0
        sceneFrame = Anidex.animEnd.rawValue
        animNow = .startup
        scene.isPaused = false
        scene.sprite.isPaused = false
    }

    func startupAnim() {   //Log(String(format:"⚆ %.1f",sceneFrame))
        
        if startupTime==0 {
            startupTime = timeNow
            finishTimer.invalidate()
            dots.selectTime(Date().timeIntervalSince1970)
            if let table = table,
                let timeEvent = MuEvents.shared.timeEvent {
                table.scrollSceneEvent(timeEvent)
            }
            dots.dotNow = 0.0
            sceneFrame = Anidex.animEnd.rawValue
            Say.shared.sayCurrentTime(nil, false)
            return
        }
        else {
            let timeElapsed = Float(timeNow - startupTime)
            let pause1 = Float(0.50)
            let fade   = Float(1.00)
            let pause2 = Float(3.00)
            let fold   = Float(3.50)
            let pause3 = Float(4.00)
            let deltaSpoke = spokeWheel - spokeUp

              func fadeFrameIn() -> Float {
                let fadeRatio = Float(timeElapsed/fade)
                let frame = spokeFan - fadeRatio // 38 -> 37
                return frame
            }
            func foldFrameOut() -> Float {
                let ratio = Float(timeElapsed-pause1)/(fade-pause1)
                let frame = spokeWheel - deltaSpoke * (1 - ratio)
                return frame
            }
            func foldFrameIn() -> Float {
                let ratio = Float(timeElapsed-pause2)/(fold-pause2) // translate 3..<4 to 0..<1
                let frame = spokeWheel - deltaSpoke * ratio
                return frame
            }
            
            func wheelClosures() -> Float {
                Closures.shared.execClosures()
                return spokeWheel
            }
            func pauseOnCurrentHour() -> Float {
                if let event = dots.sayFirstMark(getDotIndex()) {
                    table?.scrollSceneEvent(event) // pause on current hour
                    animNow = animNow.rawValue > 0 ? .futrMark : .pastMark
                }
                else { // continue to next hour
                    animNow = .futrScan
                }
                return spokeFan
            }

            switch timeElapsed {
            case      0 ..< pause1:     sceneFrame = Anidex.animEnd.rawValue
            case pause1 ..< fade:       sceneFrame = foldFrameOut()
            case   fade ..< pause2:     sceneFrame = wheelClosures()
            case pause2 ..< fold:       sceneFrame = foldFrameIn()
            case   fold ..< pause3:     sceneFrame = Anidex.animEnd.rawValue
            case pause3 ..< .infinity:  sceneFrame = pauseOnCurrentHour()
            default: break
            }
        }
    }

    /**
     SKScene callback for every frame, enum var animNow calls inner func

     pausing()      // currently paused
     scanning()     // advance sceneFrame, check if new dot has a marked event
     marking()      // while pausing on marked event, check for another event
     fanOut()       // fan out spokes animation
     wheelFade()    // fade in wheel of spokes when dotNow approaches 0
     spokeFade()    // fade to single spoke when dotNow leaves hour 0
     recSpokeUpDn() // animate spoke up down while recording
     recFinishAnim() // resume with previous palette at hour 0
     */
    func updateScene(_ currentTime:TimeInterval) -> Bool {

       timeNow = currentTime

        switch animNow {
        case .futrPause,  .pastPause:   pausing()
        case .futrMark,   .pastMark:    marking()
        case .futrScan,   .pastScan:    scanning()
        case .futrFanOut, .pastFanOut:  fanOut()
        case .futrWheel,  .pastWheel:   wheelFade()
        case .futrSpoke,  .pastSpoke:   spokeFade()
        case .recSpoke:                 recSpokeUpDn()
        case .recFinish:                recFinishAnim()
        case .startup:                  startupAnim()
        }
        timePrev = timeNow
        let changedFrame = sceneFrame != lastFrame
        return changedFrame
    }
 
}
