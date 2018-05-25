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

    private var resetValues = true // reset values with current value
    
    override init() {
        
        super.init()
        if manager.isAccelerometerAvailable {
            manager.deviceMotionUpdateInterval = 1.0/60.0
        }
    }
      
    /** translate watch or iPhone motion into gesture */
    func goMotion(_ motion:CMDeviceMotion!) {

        if resetValues {  Log("⊕ resetValues")
            resetValues = false
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


    func updateMotionValues() {

        // nodding gesture while watch went inactive and active again within waitingPeriod
        let deltaTime = startTime - stopTime

        if lastGesture == .pitchYou,
            deltaTime < Record.shared.waitingPeriod {
            valMotion.subtractPitchTime(deltaTime)
        }
        else {
            resetValues = true // reset values with current value, to bypass damping filter
        }
    }

    func startMotion() { Log("⊕ \(#function) \(lastGesture.rawValue)" )

        startTime = Date().timeIntervalSince1970
        updateMotionValues()

        if let queue =  OperationQueue.current {
            manager.startDeviceMotionUpdates(to:queue) { motion, error in

                if let motion = motion {
                    self.goMotion(motion)
                }
                else if let error = error {
                    Log("⊕ Accel error:\(error.localizedDescription)" )
                }
            }
        }
    }
    
    func stopMotion() { Log("⊕ \(#function)" )

        stopTime = Date().timeIntervalSince1970
        manager.stopDeviceMotionUpdates()
        manager.stopAccelerometerUpdates()
    }
}

