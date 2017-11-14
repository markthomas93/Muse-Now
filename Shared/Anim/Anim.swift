import UIKit

enum Anidex : Float { case
    
    animStart   =   0,  // start of animation (spoke is shown up for current hour)
    spokeDown   =   7,  // begin of single spoke bouncing down then up
    spokeUp     =  14,  // end of single spoke back up
    spokeFan    =  38,  // fan out spokes for all hours with slight wheel fade
    eachHour    = 206,  // each individual hour of the week with fading contrail
    wheelSpoke  = 213,  // main hour spoke with dimmed wheel
    wheelFade   = 220,  // complete dimmed wheel to show only spokeUp
    animEnd     = 240   // end of animate (4 seconds)
}

enum Animating : Int { case
    
    // all past < 0
    pastScan    = -6, // (-138 0] auto animNow to next mark in past
    pastFanOut  = -5, // [-.5 -1) user initiated pan or crown
    pastSpoke   = -4, // (-1 0] -> (-138 -1] fade from wheel to current spoke
    pastWheel   = -3, // (-1 0] fade in full wheel, when transition from [-138 -1]
    pastMark    = -2, // pause for a second to announce a mark
    pastPause   = -1, // pausing anywhere on past - user single tap

    // all future > 0
    futrPause   =  1, // pausing anywhere on futr - user single tap
    futrMark    =  2, // pause for a second to announce a mark
    futrWheel   =  3, // [0 1) fade in full wheel, when transition from [-138 -1]
    futrSpoke   =  4, // [0 1) -> [1 138) fade from wheel to current spoke
    futrFanOut  =  5, // (1 .3] user moved to 1st dot, so show fan
    futrScan    =  6, // [0 138) auto animate to next mark in futr

    recSpoke    = 10, // animate from current position to spoke up and down
    recFinish   = 11,  // finished recording, cleanup

    startup     = 20,  // animation when first showing
    shutdown    = 21
}

class Anim {

    static let shared = Anim()
    
    let dots    = Dots.shared
    let dayHour = DayHour.shared
    let say     = Say.shared
    
    var scene : Scene!
    var table : MuseTableDelegate!
    var closures : [Closure] = []
    
    var sceneFrame  = Float(0)
    var lastFrame   = Float(0)
    var timePrev    = TimeInterval(0) // time of previous frame
    var timeNow     = TimeInterval(0) // time of current frame

    var frames      = Anidex.animEnd.rawValue
    var animNow     = Animating.futrScan
    var animPause   = Animating.futrScan
    let spokeUp    = Anidex.spokeUp.rawValue       // show a spoke
    let spokeFan    = Anidex.spokeFan.rawValue       // show a spoke
    let spokeWheel  = Anidex.spokeFan.rawValue - 1   // show a faded wheel
    let sceneHours  = Anidex.eachHour.rawValue
    
    var crownDex    = 0
    let maxDots     = Int(24*7)
    var actionTime  = TimeInterval(0) // when did user change animation state

    // animation state
    var fanOutTime  = TimeInterval(0) // when did user transition between futr to past
    var fanOutDur   = TimeInterval(0.5) // duration of transition
    
    var spokeTime = TimeInterval(0)     // wheel fadeIn animation start time
    var spokeDur  = TimeInterval(0.5)   // wheel fadeIn animation duration
    
    var wheelTime = TimeInterval(0)     // wheel fadeIn animation start time
    var wheelDur  = TimeInterval(0.5)   // wheel fadeIn animation transition duration

    var finishTime = TimeInterval(0)  // recording animation start time
    var recSpokeDur  = TimeInterval(0.5) // recording animation transition duration
    var recSpokeFade = Float(1.0)       // push/pop color fade to white while recording
    var finishFrame = Float(0)        // starting frame to animate to zero spoke
    var recSpokeStart = false

    var startupTime = TimeInterval(0)
    var startupDur  = TimeInterval(0.5)

    var finishTimer = Timer()
    var finishDuration = TimeInterval(3.0)


    
    /// while animating paused, get a dot index, in which to mark
    func getIndexForMark() -> Int {
        
        switch animNow {
            
        case .futrPause,  .pastPause:
            
            let thisTime = Date().timeIntervalSince1970
            let deltaTime = thisTime - actionTime
            if deltaTime > 1 {
                return getDotIndex()
            }
            
        case .futrMark,   .pastMark,
             .futrScan,   .pastScan,
             .futrFanOut, .pastFanOut,
             .futrWheel,  .pastWheel,
             .futrSpoke,  .pastSpoke,
             .recSpoke,   .recFinish,
             .startup,    .shutdown:

            break
        }
        return 0
    }
    
  
}
