//  MuseFound.swift
//  Created by warren on 9/5/17.
//  Copyright © 2017 Muse. All rights reserved.

import Foundation

public enum ActionType : Int { case
    unknown,
    calendars,
    events,
    memos,
    marks,
    alarm
}

class MuseFound {

    var str: String! = nil
    var nodeAny: NodeAny! = nil
    var hops = -1

    convenience init (_ str_:String,_ nodeAny_: NodeAny!,_ hops_:Int) {
        self.init()
        str     = str_
        nodeAny = nodeAny_
        hops    = hops_
    }

    convenience init (_ from: MuseFound) {
        self.init()
        str     = from.str
        nodeAny = from.nodeAny
        hops    = from.hops
    }
}

class MuseModel {

    // var action: DoAction = .unknown
    var show = true
    var item: ActionType = .unknown
}
