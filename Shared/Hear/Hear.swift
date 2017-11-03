//  Hear.swift
//  Klio
//
//  Created by warren on 10/20/17.
//  Copyright © 2017 Muse. All rights reserved.

import Foundation
import AVFoundation

struct HearSet: OptionSet {
    let rawValue: Int
    static let mute    = HearSet(rawValue: 1 << 0)
    static let speaker = HearSet(rawValue: 1 << 1)
    static let earbuds = HearSet(rawValue: 1 << 2)
    static let remote  = HearSet(rawValue: 1 << 3)
}

class Hear {

    static let shared = Hear()
    #if os(watchOS)
    var options = HearSet([.earbuds,.remote]) // user options -- manually set
    var route   = HearSet([.mute])
    #else
    var options = HearSet([.earbuds,.speaker]) // user options -- manually set
    var route   = HearSet([.speaker])
    #endif

    var local   = HearSet([.speaker])     // this device's harware route
    var remote  = HearSet([.mute])     // other device's harware route

    // allowed output via


    var port    = "unknown port"     // audio port
    var reason  = "unknown reason"   // reason for change

    init() {

        listenForNotifications()
        updateRoute()
        updateRemote()
        updatePort()
        printLog("🎧 route: \(route) port: \(port) ")
    }

    func listenForNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleRouteChange(_:)), name: NSNotification.Name.AVAudioSessionRouteChange, object: nil)
    }

    @objc func handleRouteChange(_ notification: Notification) {

        updateReason(notification)
        updatePort()

        updateRoute()
        updateRemote()
        printLog("🎧 \(#function) route: \(route) port: \(port) reason: \(reason)  ")
    }

    func updateReason(_ notification: Notification) {

        guard
            let userInfo = notification.userInfo,
            let reasonNum = userInfo[AVAudioSessionRouteChangeReasonKey] as? NSNumber,
            let reasonUint = AVAudioSessionRouteChangeReason(rawValue: reasonNum.uintValue)
            else { printLog("🎧 unknown updateReason notification:\(notification)") ; return }
        
        switch reasonUint {
        case .oldDeviceUnavailable:     reason = "Unavailable "
        case .newDeviceAvailable:       reason = "new Device "
        case .routeConfigurationChange: reason = "Route change "
        case .categoryChange:           reason = "Category change "
        default:                        reason = "\(reasonUint)"
        }
    }

    func updatePort() {

        for output in AVAudioSession.sharedInstance().currentRoute.outputs {

            switch output.portType {
            case AVAudioSessionPortBluetoothA2DP:   port = "A2DP "
            case AVAudioSessionPortBluetoothHFP:    port = "HFP "
            case AVAudioSessionPortBluetoothLE:     port = "LE "
            case AVAudioSessionPortHeadphones:      port = "Headphones "
            default:                                port = "\(output.portType) "
            }
        }
    }

    /**
     Update from remote device via Session.
     Determine route from state if both devices
     */
    func updateFromSession(_ remote_: HearSet) {

        remote = remote_
        let oldRoute = route
        updateRoute()

        if  !route.contains(.earbuds),
            remote.contains(.earbuds),
            options.contains(.remote) {

            route = [.remote] // replace [.speaker,.mute] with [.remote]
        }
        printLog("🎧 \(#function)(\(remote) \(oldRoute) ⟶ \(route)")
    }

    func updateRoute() {

        for output in AVAudioSession.sharedInstance().currentRoute.outputs {

            switch output.portType {

            case AVAudioSessionPortBluetoothA2DP,
                 AVAudioSessionPortBluetoothHFP,
                 AVAudioSessionPortBluetoothLE,
                 AVAudioSessionPortHeadphones:

                local = .earbuds
                route = options.contains(.earbuds) ? .earbuds : .mute
                return

            default: continue
            }
        }
        local = .speaker
        route = options.contains(.speaker) ? .speaker : .mute
    }

    /**
     Get status from other device
     */
    func updateRemote() {

        Session.shared.sendMsg( ["class" : "hear",
                                 "putRoute" : route,
                                 "getRoute" : "yo"])
    }


    func play(_ local:()->()!, _ remote:()->()!) -> Bool {

        switch route {
        case .mute:                 return false
        case .remote:   remote() ;  return true
        case .earbuds:  local()  ;  return true
        case .speaker:  local()  ;  return true
        default:                    return false
        }
    }

    func getMenus() -> [StrAct] {

        var strActs = [StrAct]()

        if route.contains(.mute) {
            if      local.contains(.earbuds) { strActs.append(StrAct("hear earbuds", .hearEarbuds)) }
            else if local.contains(.speaker) { strActs.append(StrAct("hear speaker", .hearSpeaker)) }

            if      remote.contains(.earbuds) { strActs.append(StrAct("hear remote", .hearRemote)) }
        }
        else {
            if      local.contains(.remote)   { strActs.append(StrAct("mute remote", .muteRemote)) }
            else if remote.contains(.earbuds) { strActs.append(StrAct("hear remote", .hearRemote)) }

            if      local.contains(.speaker) { strActs.append(StrAct("mute speaker", .muteSpeaker)) }
            else if local.contains(.earbuds) { strActs.append(StrAct("mute earbuds", .muteEarbuds)) }
        }
        return strActs
    }

    public func doHearAction(_ act: DoAction) {

        switch act {

        case .hearRemote:   options.insert(.remote)    ; route = .remote
        case .hearSpeaker:  options.insert(.speaker)   ; route = .speaker
        case .hearEarbuds:  options.insert(.earbuds)   ; route = .earbuds
        case .hearAll:      options = [.remote, .speaker, .earbuds] ; route = local

        case .muteRemote:   options.remove(.remote)    ; route = options.contains(local) ? local : .mute
        case .muteSpeaker:  options.remove(.speaker)   ; route = options.contains(local) ? local : .mute
        case .muteEarbuds:  options.remove(.earbuds)   ; route = options.contains(local) ? local : .mute
        case .muteAll:      options = [.mute]          ; route = .mute

        default: break
        }
    }

 }
