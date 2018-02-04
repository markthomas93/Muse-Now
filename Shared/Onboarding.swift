//
//  Onboarding.swift
//  MuseNow
//
//  Created by warren on 1/23/18.
//  Copyright © 2018 Muse. All rights reserved.
//

import Foundation
public enum BoardingState: Int { case boarding = 0, completed = 1 }
class Onboard {

    static var shared = Onboard()

    var state = BoardingState.boarding

}
