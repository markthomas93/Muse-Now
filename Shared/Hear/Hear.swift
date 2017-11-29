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
    var hearSet = HearSet([.earbuds]) // user options -- manually set
    var route   = HearSet([])
    #else
    var hearSet = HearSet([.earbuds,.speaker]) // user options -- manually set
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
    func updateOptionsFromSession(_ hearSet_: HearSet) {

        hearSet = hearSet_
        let oldRoute = route
        updateRoute()
        printLog("🎧 \(#function) \(oldRoute) ⟶ \(route)")
    }

  
    func updateLocal(_ local_:HearSet) {

        local = local_

        switch local {

        case .earbuds:

            if      hearSet.contains(.earbuds)  { route = [.earbuds] }
            else if hearSet.contains(.speaker)  { route = [.speaker] }
            else                                { route = [] }

        default: // speaker

            if hearSet.contains(.speaker)  { route = [.speaker] }
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
        return hearSet.contains(local)
    }

    func getMenus() -> [StrAct] {

        var strActs = [StrAct]()

        if route.isEmpty {
            
            if hearSet.contains(.speaker) { strActs.append(StrAct("hear speaker", .hearSpeaker)) }
            if hearSet.contains(.earbuds) { strActs.append(StrAct("hear earbuds", .hearEarbuds)) }
        }
        else {
            if      local.contains(.speaker) { strActs.append(StrAct("mute speaker", .muteSpeaker)) }
            else if local.contains(.earbuds) { strActs.append(StrAct("mute earbuds", .muteEarbuds)) }
        }
        return strActs
    }

    public func doHearAction(_ act: DoAction, isSender: Bool = false) {

        switch act {

        case .hearSpeaker:  hearSet.insert(.speaker)
        case .hearEarbuds:  hearSet.insert(.earbuds)

        case .muteSpeaker:  hearSet.remove(.speaker)
        case .muteEarbuds:  hearSet.remove(.earbuds)
 
        default: break
        }
        Settings.shared.updateArchive()
        updateRoute()
        if isSender {
            Session.shared.sendMsg(["class"   : "HearSet",
                                    "putSet"  : hearSet.rawValue])
        }

    }

 }
