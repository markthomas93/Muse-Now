//
//  Hear+Action.swift
//  Klio
//
//  Created by warren on 10/21/17.
//  Copyright © 2017 Muse. All rights reserved.
//

import Foundation

class HearVia {

    struct HearSet: OptionSet {
        let rawValue: Int
        static let speaker = HearSet(rawValue: 1 << 0)
        static let earbuds = HearSet(rawValue: 1 << 1)
        static let remote  = HearSet(rawValue: 1 << 2)
    }
    var hearSet = HearSet([.earbuds,.remote])

    init(_ hearSet_:HearSet) {
        hearSet = hearSet_
    }

    // speech to text volume
    public func doHearAction(_ act: DoAction) {

        switch act {

        case .hearRemote:   hearSet.insert(.remote)
        case .hearSpeaker:  hearSet.insert(.speaker)
        case .hearEarbuds:  hearSet.insert(.earbuds)
        case .hearAll:      hearSet = [.remote, .speaker, .earbuds]

        case .muteRemote:   hearSet.remove(.remote)
        case .muteSpeaker:  hearSet.remove(.speaker)
        case .muteEarbuds:  hearSet.remove(.earbuds)
        case .muteAll:      hearSet = []

        default: break
        }
    }

    func play(_ local:()->()!, _ remote:()->()!) {
        let route = Hear.shared.route
        var canPlay = false
        switch route {
        case .unknown: canPlay = !hearSet.intersection([.speaker]).isEmpty
        case .remote:  canPlay = !hearSet.intersection([.remote]).isEmpty
        case .speaker: canPlay = !hearSet.intersection([.speaker]).isEmpty
        case .earbuds: canPlay = !hearSet.intersection([.earbuds]).isEmpty
        }
        if canPlay {
            if route == .remote { remote() }
            else                { local() }
        }
    }
}
