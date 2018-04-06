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
    
    // wait before stoping samples after inactive, for false screen blank while nodding
    var motionTimer  = Timer()
    
    // for testLower
    var gravityPrev = CMAcceleration(x:0, y:0, z:0)
    var firstSample = true // no gravityPrev yet, so set it to first sample
    
    // for testNod
    var nodPlusT = TimeInterval(0)
    var nodNegT = TimeInterval(0)
    
    // for TestShake user Acceleration
    var shakeBothThreshold = 1.2
    var shakeWindow = TimeInterval(0.3) // time window where y -> z -> y
    
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
            manager.deviceMotionUpdateInterval = 1.0/60.0
            //manager.gyroUpdateInterval = 1.0/5.0
        }
    }

      
    // translate motion into gesture
    // for watch, detect wrist lower, in which case
    // turn off autorotating so when raising wrist
    // the screen will be rightside up
    
    func goMotion(_ motion:CMDeviceMotion!) {

        valMotion.testMotion(motion)
        
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
            
            //printAccleration("shake2",motion)
            
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
        if gestureType != .lower,
            testLower(motion) {
            
            //printGravity("lower",motion)
            triggerGesture(.lower)
            #if os(watchOS)
                WKExtension.shared().isAutorotating = false
            #endif
            lowerAction()
        }
            // shake first time
        else if testShake(motion) {
            
            //printAccleration("shake1",motion)
            triggerGesture(.shake1)
            shake1Timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false, block: { _ in
                self.shake1Action()
            })
        }
            // nod wrist slowley
        else if testNod(motion) {
            
            //printRotationRate("nod",motion)
            triggerGesture(.nod)
            nodAction()
        }
            // trace events not captures by gesture
        else {
            // printAccleration("",motion)
        }
    }

    func startMotion() {  Log("⊕ Motion::\(#function)" )
        
        motionTimer.invalidate()
        firstSample = true

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
        
        #if os(watchOS)
            //?? WKExtension.shared().isAutorotating = true
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

