//
//  Motion+Gesture.swift
//  MuseNow
//
//  Created by warren on 4/5/18.
//  Copyright © 2018 Muse. All rights reserved.
//

import Foundation
import CoreMotion

extension Motion {
    // gesture actions
    
    func shake1Action() { Record.shared.finishRecording() }
    func shake2Action() { Record.shared.recordAudioDelete() }
    func nodAction()    { Record.shared.recordAudioAction() }
    func lowerAction()  { Record.shared.finishRecording() }
    
    func testShake(_ motion:CMDeviceMotion!) -> Bool {
        
        let nowTime = Date().timeIntervalSince1970
        #if os(watchOS)
            let m = motion.userAcceleration.y
        #else
            let m = motion.userAcceleration.x
        #endif
        
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
        if m > shakePlusThreshold {
            if  shakePlusV < m {
                shakePlusV = m
                shakePlusT = nowTime
                return triggerShake()
            }
        }
        else if m < shakeNegTheshold {
            if  shakeNegV > m {
                shakeNegV = m
                shakeNegT = nowTime
                return triggerShake()
            }
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
        
        if !Memos.shared.memoSet.contains(.nod2Rec) {
            return false
        }
        
        let nowTime = Date().timeIntervalSince1970
        
        if let motion = motion {
            
            let rotateX = motion.rotationRate.x
            
            if abs(rotateX) > 7.0 {
                
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
}

