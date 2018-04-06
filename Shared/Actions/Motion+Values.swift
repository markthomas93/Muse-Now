//
//  Motion+Values.swift
//  MuseNow
//
//  Created by warren on 4/5/18.
//  Copyright © 2018 Muse. All rights reserved.
//

import Foundation
import CoreMotion

class ValDir {

    public enum Direction: String { case
        neutral = "0",
        positive = "+",
        negative = "-"
    }

    static var nextId = 0
    static func getNextId() -> Int { nextId += 1; return nextId }
    static var threshold = Double(0.9)

    var id:  Int!
    var val: Double!
    var dir: Direction
    var time: TimeInterval

    init (_ val_:Double,_ dir_:Direction,_ time_:TimeInterval) {
        id = ValDir.getNextId()
        val = val_
        dir = dir_
        time = time_
    }

    func testNewVal(_ newVal:Double) -> Direction {
        switch dir {

        case .neutral:

            return newVal > 0 ? .positive : .negative

        case .positive:

            if newVal - val > 0 {
                val = newVal
                return .neutral
            }
            else if newVal - val < -ValDir.threshold {
                return .negative
            }
            else {
                return .neutral
            }

        case .negative:

            if val - newVal > 0 {
                val = newVal
                return .neutral
            }
            else if val - newVal < -ValDir.threshold {
                return .positive
            }
            else {
                return .neutral
            }
        }
    }

}

class ValDirs {

    static var timeSpan = TimeInterval(1.0)

    var title: String
    var prev:ValDir!
    var valDirs = [ValDir]()

    init(_ title_:String) {
        title = title_
        prev = ValDir(0,.neutral,0)
    }

    func newVal(_ newVal:Double,_ time:TimeInterval) {
        let dir = prev.testNewVal(newVal)
        if dir != .neutral {
            prev = ValDir(newVal, dir, time)
            var newDirs = [ValDir]()
            for valDir in valDirs {
                if time - valDir.time < ValDirs.timeSpan {
                    newDirs.append(valDir)
                }
            }

            newDirs.append(prev)
            valDirs = newDirs

            if valDirs.count > 2 {
                var logStr = "⊕ \(title)"
                for valDir in valDirs {
                    let deltaTime = time - valDir.time
                    logStr += String(format:" \(valDir.dir.rawValue)(%.f %5.2f)",deltaTime*1000,valDir.val)
                }
                Log(logStr)
            }
        }
    }
}

class ValXYZ {

    var xx: ValDirs!
    var yy: ValDirs!
    var zz: ValDirs!
    var title: String!

    init (_ title_:String) {

        title = title_
        xx = ValDirs(title + "_x")
        yy = ValDirs(title + "_y")
        zz = ValDirs(title + "_z")
    }

    func testAdd(_ x:Double,_ y:Double,_ z:Double,_ t:TimeInterval) {
        xx.newVal(x,t)
        yy.newVal(y,t)
        zz.newVal(z,t)
    }
}

class ValMotion {

    var rotat = ValXYZ("r")
    var grav  = ValXYZ("g")
    var accel = ValXYZ("a")


    func testMotion (_ dm:CMDeviceMotion) {
        rotat.testAdd( dm.rotationRate.x,
                       dm.rotationRate.y,
                       dm.rotationRate.z,
                       dm.timestamp)

        grav.testAdd( dm.gravity.x,
                      dm.gravity.y,
                      dm.gravity.z,
                      dm.timestamp)

        accel.testAdd(dm.userAcceleration.x,
                      dm.userAcceleration.y,
                      dm.userAcceleration.z,
                      dm.timestamp)
    }
}
