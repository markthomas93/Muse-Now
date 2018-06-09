//  Motion+Values.swift
//  MuseNow
//
//  Created by warren on 4/5/18.
//  Copyright © 2018 Muse. All rights reserved.⇄


import Foundation
import CoreMotion
import WatchKit


public func |= (leftSide : inout Bool, rightSide : Bool) {
    leftSide = leftSide || rightSide
}

public enum Gesture: String { case
    none        = "⊡",

    pitchMe     = "↥",
    pitchYou    = "↧",
    nodding     = "⥮", // pitchMe followed by pitchYou, within timeframe
    nodding2    = "⥮²", // pitchMe followed by pitchYou, within timeframe

    rollLeft   = "↶",
    rollRight  = "↷",
    rollBoth   = "⥾",
    rollBoth2  = "⥾²",

    yawAnti     = "⟲",
    yawClock    = "⟳",
    yawBoth     = "⨀",
    yawBoth2    = "⨀²",

    slideLeft   = "⇠",
    slideRight  = "⇢",
    shake       = "⇋",
    shake2      = "⇋²"
}

class Gestures {

    var timeWindow: TimeInterval!
    var less:       Gesture!
    var more:       Gesture!
    var lessMore:   Gesture!
    var moreLess:   Gesture!
    var doubled:    Gesture!

    var halfTime    = TimeInterval(0) // time of lessMore, or more less
    var doublWin    = TimeInterval(1.0) // time window to trigger doubled
    var prevTime    = TimeInterval(0)
    var prevGesture = Gesture.none
    var prevDouble  = Gesture.none

    init(_ timeWindow_: TimeInterval,
        _ less_: Gesture,
        _ more_: Gesture,
        _ lessMore_: Gesture,
        _ moreLess_: Gesture,
        _ doubled_ : Gesture = .none,
        _ doublWin_: TimeInterval = 1.5) {

        timeWindow = timeWindow_
        less = less_
        more = more_
        lessMore = lessMore_
        moreLess = moreLess_
        doubled = doubled_
    }

    func testGesture(_ deltaTime:TimeInterval,_ prev:Int,_ next:Int,_ timestamp: TimeInterval) -> Gesture {

        func testDoubled(_ gesture: Gesture) -> Gesture {

            let deltaHalf = timestamp - halfTime
            //let deltaHalfMsec = trunc(deltaHalf * 1000)

            // expire prevDouble if past window
            if deltaHalf > doublWin {
                prevDouble = .none
            }
            // some gestures like shake may have symetric back forth, where
            // less -> more and more -> less trigger
            // as in Gestures(0.3,.slideLeft,.slideRight,.shake,.shake,.shake2)
            // so, eliminate an interim trigger between first back and forth and double
            // let sameDouble = [.none, gesture].contains(prevGesture) //== .none || prevDouble ==  gesture

            // some gestures like nodding must enforce sequence, where:
            // less -> more, not more -> less, so: the value for moreLess == Less
            // as in Gestures(1.0,.pitchYou,.pitchMe,.nodding,.pitchYou,.nodding2)
            let isUnique = (
                (gesture == moreLess && moreLess != less) ||
                (gesture == lessMore && lessMore != more))

            if isUnique {

                if deltaHalf < doublWin {
                    //Log("⊕ + \(deltaHalfMsec) \(doubled.rawValue)")
                    halfTime = 0
                    prevGesture = doubled
                    prevDouble = gesture
                    return doubled
                }
                else {
                    //Log("⊕ ? \(deltaHalfMsec) \(gesture.rawValue)")
                    halfTime = timestamp
                    prevGesture = gesture
                    return gesture
                }
            }
            else {
                //Log("⊕ = \(deltaHalfMsec) \(gesture.rawValue)")
                prevGesture = gesture
                return gesture
            }
        }

        func singleGesture(_ gesture:Gesture) -> Gesture {

            prevGesture = gesture
            return gesture
        }

        let backForth = (
        /**/    lessMore != more && lessMore == prevGesture ||
                moreLess != less && moreLess == prevGesture ||
                doubled == prevGesture)

        if  !backForth, deltaTime < timeWindow {
            if prev < 0 && next > 0 { return testDoubled(lessMore) }
            if prev > 0 && next < 0 { return testDoubled(moreLess) }
        }

        if next < 0 { return singleGesture(less) }
        if next > 0 { return singleGesture(more) }
        return .none
    }

}

class ValDir {

    var val: Double!    // value
    var dir: Int        // direction

    init (_ val_:Double,_ dir_:Int) {
        val = val_
        dir = dir_
    }
}

class ValDirs {

    static var timeSpan = TimeInterval(1.0)

    var title: String
    var valDirs = [ValDir]()
    var deltaVal = Double(0)
    var filteredVal = Double(0)
    var filterFactor = Double(0.62) // add portion of deltaNew to filteredVal
    var threshold: Double!         // minimum change in filteredVal to trigger new gesture
    var bounds = Double(0)         // range of input, useful for intervals that reset to zero past a full rotation

    var direction = 0               // == -1 backwards, 0 neutral, 1 forwards
    var startTime = TimeInterval(0) //
    var deltaTime = TimeInterval(0)

    init(_ title_:String,_ threshold_:Double,_ bounds_:Double) {
        title = title_
        threshold = threshold_
        filteredVal = 0
        direction = 0
        valDirs = [ValDir(0,0),ValDir(0,0)]
        bounds = bounds_
    }

    /**
     filter new value and when past a threshold,
     pass along to see if it triggers a new gesture.
    */
    func testVal(_ newVal:Double,_ direction_:Int,_ timestamp:TimeInterval,_ gestures:Gestures) -> Gesture {

        var deltaNew = newVal - filteredVal
        if      deltaNew >  bounds { deltaNew -= bounds }
        else if deltaNew < -bounds { deltaNew += bounds }

        filteredVal += deltaNew * filterFactor

        if abs(filteredVal - valDirs[1].val) < threshold {
            return .none
        }
        let deltaNext = abs(valDirs[1].val - filteredVal)
        valDirs[0] = valDirs[1]
        valDirs[1] = ValDir(filteredVal, direction)

        deltaVal += deltaNext
        deltaTime = timestamp - startTime
        startTime = timestamp
        let dir0 = valDirs[0].dir // previous direction
        let dir1 = valDirs[1].dir // current direction

        return gestures.testGesture(deltaTime, dir0, dir1, timestamp)
    }

    @discardableResult
    func newVal(_ newVal:Double,_ direction_:Int ,_ timestamp:TimeInterval,_ gestures:Gestures) -> Gesture {

        if direction_ == 0 || direction != direction_ {

            direction = direction_
            filteredVal = newVal
            deltaVal = 0

            if direction_ == 0 {
                valDirs[0] = ValDir(filteredVal,direction)
                valDirs[1] = ValDir(filteredVal,direction)
            }

            return .none
        }

        return testVal(newVal,direction_,timestamp,gestures)
    }

}

class ValMotion {

    var rotatX: ValDirs!
    var rotatY: ValDirs!
    var rotatZ: ValDirs!

    var aPitch: ValDirs!
    var aRoll:  ValDirs!
    var aYaw:   ValDirs!
    var accel:  ValDirs!

    var ignoreGestures = Gestures(0,.none,.none,.none,.none,.none)

    var aPitchGestures = Gestures(1.0,.pitchYou,.pitchMe,.nodding,.pitchYou,.nodding2)
    var aRollGestures  = Gestures(1.0,.rollLeft,.rollRight,.rollBoth,.rollBoth,.rollBoth2)
    var aYawGestures   = Gestures(1.0,.yawClock,.yawAnti,.yawBoth,.yawBoth,.yawBoth2)
    var accelGestures  = Gestures(0.3,.slideLeft,.slideRight,.shake,.shake,.shake2)


    var lastShake = TimeInterval(0)

    public enum GravRef: String { case crownLeft, crownRight, iPhone }

    #if os(watchOS)
    var gravRef: GravRef = WKInterfaceDevice.current().crownOrientation == .left ? .crownLeft : .crownRight
    #else
    var gravRef: GravRef = .iPhone
    #endif

    init() {
        let pi = Double.pi
        let inf = Double.infinity

        rotatX = ValDirs("rotatX", 0.250, inf)
        rotatY = ValDirs("rotatY", 0.250, inf)
        rotatZ = ValDirs("rotatZ", 0.250, inf)

        aPitch = ValDirs("aPitch", pi/6, pi/2)
        aRoll  = ValDirs("aRoll",  pi/6, pi)
        aYaw   = ValDirs("aYaw",   pi/6, pi)

        accel = ValDirs("accel",   1.2 , inf)
    }


    func testRotation(
        _ rotation: ValDirs, _ newRate: Double,      // example: rotatX, dm.rotationRate.x
        _ attitude: ValDirs, _ newValue: Double,     // example: aPitch, dm.attitude.pitch
        _ timestamp: TimeInterval, // dm.timestamp
        _ gestures: Gestures) -> Gesture
    {
        let val = rotation.valDirs[1].val!
        let dir = val > 0 ? 1 : val == 0 ? 0 : -1
        rotation.newVal(newRate, dir, timestamp, ignoreGestures)
        return attitude.newVal(newValue, rotation.valDirs[1].dir, timestamp, gestures)
    }

    /**
     for watch nodding may stop/start motion, so subtract deltaTime
    */
    func subtractPitchTime(_ deltaTime:TimeInterval) {
        rotatX.startTime += deltaTime
        aPitch.startTime += deltaTime

    }
    /**
     when starting motion, reset values from current state
    */
    func resetAll(_ dm:CMDeviceMotion) {

        let t = dm.timestamp

        rotatX.newVal(dm.rotationRate.x,    0, t, ignoreGestures)
        rotatY.newVal(dm.rotationRate.y,    0, t, ignoreGestures)
        rotatZ.newVal(dm.rotationRate.z,    0, t, ignoreGestures)

        aPitch.newVal(dm.attitude.pitch,    0, t, aPitchGestures)
        aRoll.newVal (dm.attitude.roll,     0, t, aRollGestures)
        aYaw.newVal  (dm.attitude.yaw,      0, t, aYawGestures)

        accel.newVal(dm.userAcceleration.x, 0, t, accelGestures)
    }

    func testAccel(_ dm:CMDeviceMotion) -> Gesture {

        let newVal = gravRef == .iPhone
        ? dm.userAcceleration.x
        : dm.userAcceleration.y

        let direction = newVal > 0 ? 1 : -1
        let gesture = accel.newVal(newVal, direction, dm.timestamp, accelGestures)
        if gesture != .none { Log("⊕ \(gesture.rawValue)") }
        return gesture
    }

    func testPitch(_ dm:CMDeviceMotion) -> Gesture {

        let gesture = testRotation(
            rotatX, gravRef == .crownLeft ? -dm.rotationRate.x : dm.rotationRate.x,
            aPitch, dm.attitude.pitch,
            dm.timestamp, aPitchGestures)

        if gesture != .none {

            Log("⊕ \(gesture.rawValue)")

//            if  let rVal = rotatX.valDirs[1]!.val,
//                let aVal = aPitch.valDirs[1]!.val {
//                Log(String(format:"⊕ %@ rx:%5.2f ap:%5.2f ∆v:%5.2f vt:%5.2f",
//                           gesture.rawValue, rVal, aVal, aPitch.deltaVal, aPitch.deltaTime))
//            }
        }
        return gesture
    }
    func testRoll(_ dm:CMDeviceMotion) -> Gesture {

        let gesture = testRotation(
            rotatY, gravRef == .crownLeft ? -dm.rotationRate.y : dm.rotationRate.y,
            aRoll, dm.attitude.roll,
            dm.timestamp,aRollGestures)

        if gesture != .none {  Log("⊕ \(gesture.rawValue)") }

        return gesture
    }

    func testYaw(_ dm:CMDeviceMotion) -> Gesture {

        let gesture = testRotation(
            rotatZ, gravRef == .crownLeft ? -dm.rotationRate.z : dm.rotationRate.z,
            aYaw, dm.attitude.yaw,
            dm.timestamp, aYawGestures)

        if gesture != .none {  Log("⊕ \(gesture.rawValue)") }

        return gesture
    }
}

