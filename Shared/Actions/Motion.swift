//  Motion.swift

import CoreMotion
import WatchKit
class Motion: NSObject {
    
    static let shared = Motion()

    let record = Record.shared
    let manager = CMMotionManager()
    var posTime = TimeInterval(0)
    var negTime = TimeInterval(0)
    var motionTimer  = Timer()
    var gravityPrev = CMAcceleration(x:0, y:0, z:0)
    var firstSample = true // no gravityPrev yet, so set it to first sample

    override init() {
        
        super.init()
        if manager.isAccelerometerAvailable {
            
            //manager.accelerometerUpdateInterval = 0.01
            manager.deviceMotionUpdateInterval  = 0.05
        }
    }

    func printGravity(_ title:String, _ motion:CMDeviceMotion) {

        Log(String(format: "⊕ \(title): %5.2f %5.2f %5.2f",
                        motion.gravity.x,
                        motion.gravity.y,
                        motion.gravity.z))
    }

    func printRotationRate(_ title:String, _ motion:CMDeviceMotion) {

        Log(String(format: "⊕ \(title): %5.2f %5.2f %5.2f",
                        motion.rotationRate.x,
                        motion.rotationRate.y,
                        motion.rotationRate.z))
    }

    /// monitor gravity changes for watch, to allow throttle motion to start recording
    func wristLower (_ motion: CMDeviceMotion!) -> Bool {

        var lowerWrist = false

        #if os(watchOS)

            if firstSample {
                firstSample = false
                gravityPrev = motion.gravity
                return false
            }
            let gravityNow = motion.gravity

            let gravityDelta = CMAcceleration(x: abs(gravityPrev.x - gravityNow.x),
                                              y: abs(gravityPrev.y - gravityNow.y),
                                              z: abs(gravityPrev.z - gravityNow.z))
            if gravityDelta.x > 0.5  {

                if gravityNow.x > 0.4 {

                    lowerWrist = true

                    if Record.shared.isRecording {
                        Record.shared.finishRecording()
                    }

                }
                else if gravityNow.x < 0.25 {
                    //? WKExtension.shared().isAutorotating = true
                }
                gravityPrev = gravityNow
            }
        #endif
        return lowerWrist
    }

    /** trigger a wristThrottle when user twists wrist back and forth within 1.0 second
     - via activate
     - note:
     Initial direction of twist can be +/-, paired with opposite -/+ to trigger wristThrottle
     started with more complex filtering, such as ML to recognize snapped fingers
     but, found that a simple twist of wrist back and forth yieled a rotationRate.x,
     which was isolated from both false positives and negatives
     */
    func wristThrottle(_ motion: CMDeviceMotion!) -> Bool {
        
        if let motion = motion {
            
            let rotat = motion.rotationRate

            if abs(rotat.x) > 8.0 {

                if rotat.x > 0  {
                    
                    let nowTime = Date().timeIntervalSince1970
                    if nowTime - posTime < 1.0 { return false}             // ignore redundant + rotation
                    if nowTime - negTime < 1.0 { negTime=0; return true }  // reset -, so only trigger once
                    posTime = nowTime
                }
                else if rotat.x < 0 {
                    
                    let nowTime = Date().timeIntervalSince1970
                    if nowTime - negTime < 1.0 { return false }           // ignore redundant - rotation
                    if nowTime - posTime < 1.0 { posTime=0; return true}  // reset +, so only trigger once
                    negTime = nowTime
                }
            }
        }
        return false
    }
    
    func startMotion() {

        if manager.isAccelerometerAvailable { Log("⊕ Motion::\(#function)" )

            motionTimer.invalidate()
            firstSample = true

            #if os(watchOS)
                WKExtension.shared().isAutorotating = true
            #endif
            manager.startDeviceMotionUpdates(to: OperationQueue.current!) { motion, error in
                if let motion = motion {
                    // for watch, detect wrist lower, in which case
                    // turn off autorotating so when raising wrist
                    // the screen will be rightside up
                    #if os(watchOS)
                        if self.wristLower(motion) {
                            WKExtension.shared().isAutorotating = false
                            Record.shared.finishRecording()
                            self.printGravity("wristLower", motion)
                            return
                        }
                    #endif
                    if self.wristThrottle(motion) {
                        Record.shared.recordAudioAction()
                        self.printRotationRate("wristThrottle", motion)
                    }
                }
                else if let error = error {
                    Log("⊕ Motion::\(#function) error:\(error.localizedDescription)" )
                }
            }
        }
    }

    func stopMotion() {
        if manager.isAccelerometerAvailable {
            motionTimer = Timer.scheduledTimer(withTimeInterval: 1.5, repeats: false, block: {_ in
                // self.manager.stopDeviceMotionUpdates()
                // self.manager.stopAccelerometerUpdates()
                 Log("⊕ Motion::\(#function)" )
            })
        }
    }
}

