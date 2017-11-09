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
    var remote  = HearSet([])     // other device's harware route

    var reason  = "unknown reason"   // reason for change

    init() {

        listenForNotifications()
        updateRoute()
        updateRemoteDevice()
        printLog("🎧 route: \(route)")
    }

    func listenForNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleRouteChange(_:)), name: NSNotification.Name.AVAudioSessionRouteChange, object: nil)
    }

    @objc func handleRouteChange(_ notification: Notification) {

        updateReason(notification)
        updateRoute()
        updateRemoteDevice()
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
        printLog("🎧 \(#function)(\(remote) \(oldRoute) ⟶ \(route)")
    }

    /**
     Update from remote device via Session.
     Determine route from state if both devices
     */
    func updateRemoteFromSession(_ remote_: HearSet) {

        remote = remote_
        let oldRoute = route
        updateRoute()
        printLog("🎧 \(#function)(\(remote) \(oldRoute) ⟶ \(route)")
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


    /**
     Get status from other device
     */
    func updateRemoteDevice() {

        Session.shared.sendMsg( ["class"       : "HearVia",
                                 "putRouteNow" : local.rawValue,
                                 "getRouteNow" : "yo"])
    }


    func canPlay() -> Bool {
        return options.contains(local)
    }

    func getMenus() -> [StrAct] {

        var strActs = [StrAct]()

        if route.isEmpty {
            if      local.contains(.earbuds) { strActs.append(StrAct("hear earbuds", .hearEarbuds)) }
            else if local.contains(.speaker) { strActs.append(StrAct("hear speaker", .hearSpeaker)) }

            //if      remote.contains(.earbuds) { strActs.append(StrAct("hear remote", .hearRemote)) }
        }
        else {
            //if      local.contains(.remote)   { strActs.append(StrAct("mute remote", .muteRemote)) }
            //else if remote.contains(.earbuds) { strActs.append(StrAct("hear remote", .hearRemote)) }

            if      local.contains(.speaker) { strActs.append(StrAct("mute speaker", .muteSpeaker)) }
            else if local.contains(.earbuds) { strActs.append(StrAct("mute earbuds", .muteEarbuds)) }
        }
        return strActs
    }

    public func doHearAction(_ act: DoAction, isSender: Bool = false) {

        switch act {

        case .hearSpeaker:  options.insert(.speaker)
        case .hearEarbuds:  options.insert(.earbuds)

        case .muteSpeaker:  options.remove(.speaker)
        case .muteEarbuds:  options.remove(.earbuds)
 
        default: break
        }
        updateRoute()
        if isSender {
            Session.shared.sendMsg(["class"       : "HearVia",
                                    "putOptions"  : options.rawValue,
                                    "putRouteNow" : route.rawValue  ])
        }

    }

 }
