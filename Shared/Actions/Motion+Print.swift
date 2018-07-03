//
//  Motion+Print.swift
// muse •
//
//  Created by warren on 4/5/18.
//  Copyright © 2018 Muse. All rights reserved.
//

import Foundation
import CoreMotion

extension Motion {

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

}
