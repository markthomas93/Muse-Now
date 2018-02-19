//  Motion.swift

import CoreMotion
import WatchKit

public enum GestureType: String { case
    none    = "none",
    shake1  = "shake1",
    shake2  = "shake2",
    nod     = "nod",
    tilt    = "tilt",
    lower   = "lower"
}

class Motion: NSObject {
    
    static let shared = Motion()

    let manager = CMMotionManager()

    // wait before stoping samples after inactive, for false screen blank while nodding
    var motionTimer  = Timer()

    // for testLower
    var gravityPrev = CMAcceleration(x:0, y:0, z:0)
    var firstSample = true // no gravityPrev yet, so set it to first sample

    // for testNod
    var nodPlusT = TimeInterval(0)
    var nodNegT = TimeInterval(0)

    // for TestTilt user Acceleration
    var yThreshold = 0.618
    var zThreshold = 0.618
    var tiltWindow = TimeInterval(0.3) // time window where y -> z -> y
    var yTiltT1 = TimeInterval(0)    // 1st part of y -> z -> y
    var zTiltT2 = TimeInterval(0)    // 2nd part of y -> z -> y

    // for TestShake user Acceleration
    var shakeBothThreshold = 1.2
    var shakeWindow = TimeInterval(0.3) // time window where y -> z -> y
    var shakePrev: CMAcceleration!
    var yShakeV1 = 0.0
    var yShakeT1 = TimeInterval(0)    // 1st part of y -> y, where abs(t1-t1) > 1.5

    // TestShake2
    var shakePlusV = 0.0
    var shakeNegV = 0.0
    var shakePlusT = TimeInterval(0)
    var shakeNegT = TimeInterval(0)
    var shakeNegTheshold = -0.5
    var shakePlusThreshold = 0.5
    var shake1Timer = Timer()

    var gestureType = GestureType.none
     var gestureTime = TimeInterval(0)



    override init() {
        
        super.init()
        if manager.isAccelerometerAvailable {
            //manager.accelerometerUpdateInterval = 0.01 // 100 fps
            manager.deviceMotionUpdateInterval = 1.0/30.0
            //manager.gyroUpdateInterval = 1.0/5.0
        }
    }

    func printGravity(_ title:String,_ motion:CMDeviceMotion!) {

        Log(String(format: "⊕ \(title): %5.2f %5.2f %5.2f",
            motion.gravity.x,
            motion.gravity.y,
            motion.gravity.z))
    }

    func printAccleration(_ title:String,_ motion:CMDeviceMotion!) {

        let x = motion.userAcceleration.x
        let y = motion.userAcceleration.y
        let z = motion.userAcceleration.z
        let d = sqrt(x*x + y*y + z*z)
        Log(String(format: "⊕ \(title): (%5.2f,%5.2f,%5.2f):%5.2f", x, y, z, d))
    }

    func printRotationRate(_ title:String, _ motion:CMDeviceMotion!) {

        Log(String(format: "⊕ \(title): %5.2f %5.2f %5.2f",
            motion.rotationRate.x,
            motion.rotationRate.y,
            motion.rotationRate.z))
    }

      func testShake(_ motion:CMDeviceMotion!) -> Bool {

        let nowTime = Date().timeIntervalSince1970
        let y = motion.userAcceleration.y

        // fire when extremes exceed threshold
        func triggerShake() -> Bool {
            if  abs(shakePlusT - shakeNegT) < shakeWindow,
                abs(shakePlusV - shakeNegV) > shakeBothThreshold {
                shakePlusV = 0
                shakeNegV = 0
                return true
            }
            return false
        }
        // remove stale samples
        if nowTime - shakePlusT > shakeWindow {
            shakePlusT = 0
            shakePlusV = 0
        }
        if nowTime - shakeNegT > shakeWindow {
            shakeNegT = 0
            shakeNegV = 0
        }

        // sample extreme ranges
        if y > shakePlusThreshold {
            if  shakePlusV < y {
                shakePlusV = y
                shakePlusT = nowTime
                return triggerShake()
            }
        }
        else if y < shakeNegTheshold {
            if  shakeNegV > y {
                shakeNegV = y
                shakeNegT = nowTime
                return triggerShake()
            }
        }
        return false
    }

     func testTilt(_ motion:CMDeviceMotion!) -> Bool {
        
        let nowTime = Date().timeIntervalSince1970

        let y = motion.userAcceleration.y
        let z = motion.userAcceleration.z
        
        // did triger y after triggering z?
        if  abs(y) > yThreshold {
            if nowTime - zTiltT2 < tiltWindow {
                return true
            }
            else {
                yTiltT1 = nowTime
                return false
            }
        }
        // crossed z after y
        if  abs(z) > zThreshold,
            nowTime - yTiltT1 < tiltWindow {
            zTiltT2 = nowTime
        }
        return false
    }

    /// monitor gravity changes for watch, to allow throttle motion to start recording
    func testLower (_ motion: CMDeviceMotion!) -> Bool {

        func isLoweringWrist() -> Bool {

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
                    return true
                }
                else if gravityNow.x < 0.25 {
                    //? WKExtension.shared().isAutorotating = true
                }
                gravityPrev = gravityNow
            }
            return false
        }

        // begin

        #if os(watchOS)
            return isLoweringWrist()
        #else
            return false
        #endif
    }

    /**
     trigger a testNod when user twists wrist back and forth within 1.0 second
     - via activate
     - note:
     Initial direction of twist can be +/-, paired with opposite -/+ to trigger testNod
     started with more complex filtering, such as ML to recognize snapped fingers
     but, found that a simple twist of wrist back and forth yieled a rotationRate.x,
     which was isolated from both false positives and negatives
     */
    func testNod(_ motion: CMDeviceMotion!) -> Bool {

        let nowTime = Date().timeIntervalSince1970

        if let motion = motion {
            
            let rotateX = motion.rotationRate.x

            if abs(rotateX) > 8.0 {

                if rotateX > 0  {

                    if nowTime - nodPlusT < 1.0 { return false }            // ignore redundant + rotation
                    if nowTime - nodNegT  < 1.0 { nodNegT=0; return true }  // reset -, so only trigger once
                    nodPlusT = nowTime
                }
                else if rotateX < 0 {

                    if nowTime - nodNegT  < 1.0 { return false }            // ignore redundant - rotation
                    if nowTime - nodPlusT < 1.0 { nodPlusT=0; return true}  // reset +, so only trigger once
                    nodNegT = nowTime
                }
            }
        }
        return false
    }
    // gesture actions

    func shake1Action() { Record.shared.recordAudioAction() }
    func shake2Action() {}
    func tiltAction()   { Record.shared.recordAudioAction() }
    func nodAction()    { Record.shared.recordAudioAction() }
    func lowerAction()  { Record.shared.recordAudioAction() }

    // translate motino into gesture
    // for watch, detect wrist lower, in which case
    // turn off autorotating so when raising wrist
    // the screen will be rightside up

    func goMotion(_ motion:CMDeviceMotion!) {

        let nowTime = Date().timeIntervalSince1970

        func triggerGesture(_ type: GestureType) {
            gestureType = type
            gestureTime = nowTime

            nodPlusT = 0
            nodNegT = 0

            shakeNegT = 0
            shakePlusT = 0
            shakeNegV = 0
            shakePlusV = 0
        }

        // efficacy period before testing again

        // second shake interrupts shake1 and acts
        if gestureType == .shake1,
            nowTime - gestureTime > 0.25, // 1st shake recovery
            nowTime - gestureTime < 1.00, // 2nd shake window
            testShake(motion) {

            printAccleration("shake2",motion)

            shake1Timer.invalidate()
            triggerGesture(.shake2)
            shake2Action()
            return
        }
            // recovery period for non shake1 gesture
        else if nowTime - gestureTime < 2.0 {
            return
        }
        // lowering wrist is same a
        if testLower(motion) {

            printGravity("lower",motion)
            triggerGesture(.lower)
            #if os(watchOS)
                WKExtension.shared().isAutorotating = false
            #endif
            lowerAction()
        }
            // shake first time
        else if testShake(motion) {

            printAccleration("shake1",motion)
            triggerGesture(.shake1)
            shake1Timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false, block: { _ in
                self.shake1Action()
            })
        }
            // tilt wrist back up
        else if testTilt(motion) {

            printAccleration("tilt", motion)
            triggerGesture(.tilt)
            tiltAction()
        }
            // nod wrist slowley
        else if testNod(motion) {

            printRotationRate("nod",motion)
            triggerGesture(.nod)
            nodAction()
        }
            // trace events not captures by gesture
        else {
            printAccleration("",motion)
        }
    }

    func startAccelerometer() {

        if manager.isAccelerometerAvailable { Log("⊕ Motion::\(#function)" )

            manager.startDeviceMotionUpdates(to: OperationQueue.current!) { motion, error in
                if let motion = motion {
                    self.goMotion(motion)
                }
                else if let error = error {
                    Log("⊕ Accel error:\(error.localizedDescription)" )
                }
            }
            #if false // not available on watch
                manager.startGyroUpdates(to: OperationQueue.current!) { data, error in
                    if let  info = data?.rotationRate{
                        Log("⊕ Gyro \(trunc(info.x*1000)) \(trunc(info.y*1000))  \(trunc(info.z*1000)) ")
                    }
                }
            #endif
        }
    }

    func startMotion() {

        motionTimer.invalidate()
        firstSample = true
        startAccelerometer()

        #if os(watchOS)
            WKExtension.shared().isAutorotating = true
        #endif
    }

    func stopMotion() {
        if manager.isAccelerometerAvailable {
            motionTimer = Timer.scheduledTimer(withTimeInterval: 1.5, repeats: false, block: {_ in
                self.manager.stopDeviceMotionUpdates()
                self.manager.stopAccelerometerUpdates()
                 Log("⊕ Motion::\(#function)" )
            })
        }
        if manager.isGyroAvailable {

        }
    }
}

