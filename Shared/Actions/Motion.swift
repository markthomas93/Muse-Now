//  Motion.swift

import CoreMotion
import WatchKit

public enum GestureType: String { case
    none    = "none",
    shake1  = "shake1",
    shake2  = "shake2",
    nod     = "nod",
    lower   = "lower"
}

class Motion: NSObject {
    
    static let shared = Motion()
    
    let manager = CMMotionManager()
    var valMotion = ValMotion()
    var lastGesture = Gesture.none
    var gestureTime = TimeInterval(0)
    var stopTime = TimeInterval(0)
    var startTime = TimeInterval(0)

    private var reset = true
    
    override init() {
        
        super.init()
        if manager.isAccelerometerAvailable {
            manager.deviceMotionUpdateInterval = 1.0/60.0
        }
    }
      
    /**
        translate watch or iPhone motion into gesture
     */
    func goMotion(_ motion:CMDeviceMotion!) {

        if reset {  Log("⊕ reset")
            reset = false
            valMotion.resetAll(motion)
            return
        }

        let gesture = valMotion.testPitch(motion)
        if [.pitchYou,.pitchMe,.nodding,.nodding2].contains(gesture) {

            lastGesture = gesture
            gestureTime = Date().timeIntervalSince1970
            if lastGesture == .nodding {
                Record.shared.recordAfterWaitingPeriod()
                return
            }
        }
        if valMotion.testAccel(motion) == .shake2 {

            lastGesture = .shake2
            gestureTime = Date().timeIntervalSince1970
           Record.shared.deleteRecording()

        }
        //  if valMotion.testRoll(motion) == .rollBoth { }
        //  if valMotion.testYaw(motion) == .nodding { }
    }

    /**
     nodding gesture while watch went inactive and active again within a 1 second window
     */
    func continueNodding() {

          func subtractPitchTimeOff() {

            let deltaTime = startTime - stopTime

            Log("⊕ \(#function) deltaTime:\(deltaTime)" )

            if deltaTime < Record.shared.waitingPeriod { valMotion.subtractPitchTime(deltaTime) }
            else { reset = true } // too long so start over
        }

        // begin ---------------------------------

        switch lastGesture {
        //case .nodding:  if Record.shared.recordAfterInterruption() { reset = true }
        case .pitchYou: subtractPitchTimeOff()
        default:        reset = true // reset values with current value, to bypass damping filter
        }
    }

    func startMotion() {  Log("⊕ \(#function) \(lastGesture.rawValue)" )

        startTime = Date().timeIntervalSince1970

        continueNodding()

        manager.startDeviceMotionUpdates(to: OperationQueue.current!) { motion, error in
            if let motion = motion {
                self.goMotion(motion)
            }
            else if let error = error {
                Log("⊕ Accel error:\(error.localizedDescription)" )
            }
        }
    }
    
    func stopMotion() { Log("⊕ \(#function)" )
        stopTime = Date().timeIntervalSince1970
        manager.stopDeviceMotionUpdates()
        manager.stopAccelerometerUpdates()
    }
}

