//  Hear.swift
//  Created by warren on 10/20/17.
//  Copyright © 2017 Muse. All rights reserved.

import Foundation
import AVFoundation

struct HearSet: OptionSet {
    let rawValue: Int
    static let speaker = HearSet(rawValue: 1 << 0) // 1
    static let earbuds = HearSet(rawValue: 1 << 1) // 2
    static let size = 2
}

class Hear {

    static let shared = Hear()
    #if os(watchOS)
    var options = HearSet([.earbuds]) // user options -- manually set
    var route   = HearSet([])
    #else
    var options = HearSet([.earbuds,.speaker]) // user options -- manually set
    var route   = HearSet([.speaker])
    #endif

    var local   = HearSet([.speaker])     // this device's harware route

    var reason  = "unknown reason"   // reason for change

    init() {

        listenForNotifications()
        updateRoute()
        printLog("🎧 route: \(route)")
    }

    func listenForNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleRouteChange(_:)), name: NSNotification.Name.AVAudioSessionRouteChange, object: nil)
    }

    @objc func handleRouteChange(_ notification: Notification) {

        updateReason(notification)
        updateRoute()
        printLog("🎧 \(#function) route: \(route) reason: \(reason)  ")
    }

    func updateReason(_ notification: Notification) {

        guard
            let userInfo = notification.userInfo,
            let reasonNum = userInfo[AVAudioSessionRouteChangeReasonKey] as? NSNumber,
            let reasonUint = AVAudioSessionRouteChangeReason(rawValue: reasonNum.uintValue)
            else { printLog("🎧 unknown updateReason notification:\(notification)") ; return }
        
        switch reasonUint {
        case .oldDeviceUnavailable:     reason = "Unavailable "
        case .newDeviceAvailable:       reason = "New Device "
        case .routeConfigurationChange: reason = "Route change "
        case .categoryChange:           reason = "Category change "
        default:                        reason = "\(reasonUint)"
        }
    }

    /**
     Update from remote device via Session.
     Determine route from state if both devices
     */
    func updateOptionsFromSession(_ options_: HearSet) {

        options = options_
        let oldRoute = route
        updateRoute()
        printLog("🎧 \(#function) \(oldRoute) ⟶ \(route)")
    }

  
    func updateLocal(_ local_:HearSet) {

        local = local_

        switch local {

        case .earbuds:

            if      options.contains(.earbuds)  { route = [.earbuds] }
            else if options.contains(.speaker)  { route = [.speaker] }
            else                                { route = [] }

        default: // speaker

            if options.contains(.speaker)  { route = [.speaker] }
            else                           { route = [] }
        }
    }

    func updateRoute() {

        for output in AVAudioSession.sharedInstance().currentRoute.outputs {

            switch output.portType {

            case AVAudioSessionPortBluetoothA2DP,
                 AVAudioSessionPortBluetoothHFP,
                 AVAudioSessionPortBluetoothLE,
                 AVAudioSessionPortHeadphones:

                return updateLocal([.earbuds])

            default: continue
            }
        }
        updateLocal([.speaker])
    }

    func canPlay() -> Bool {
        return options.contains(local)
    }

    func getMenus() -> [StrAct] {

        var strActs = [StrAct]()

        if route.isEmpty {
            if      local.contains(.earbuds) { strActs.append(StrAct("play earbuds", .hearEarbudsOn)) }
            else if local.contains(.speaker) { strActs.append(StrAct("play speaker", .hearSpeakerOn)) }
        }
        else {
            if      local.contains(.speaker) { strActs.append(StrAct("mute speaker", .hearSpeakerOff)) }
            else if local.contains(.earbuds) { strActs.append(StrAct("mute earbuds", .hearEarbudsOff)) }
        }
        return strActs
    }

    public func doHearAction(_ act: DoAction, isSender: Bool = false) {

        switch act {

        case .hearSpeakerOn:    options.insert(.speaker)
        case .hearEarbudsOn:    options.insert(.earbuds)

        case .hearSpeakerOff:   options.remove(.speaker)
        case .hearEarbudsOff:   options.remove(.earbuds)
 
        default: break
        }
        updateRoute()
        if isSender {
            Session.shared.sendMsg(["class"       : "HearSet",
                                    "putSet"  : options.rawValue])
        }

    }

 }
