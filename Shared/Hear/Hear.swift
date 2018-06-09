//  Hear.swift
//  Created by warren on 10/20/17.
//  Copyright © 2017 Muse. All rights reserved.

import Foundation
import AVFoundation

class Hear {

    static let shared = Hear()

    var earbuds = true
    var speaker = false

    var routeEarbuds = false
    var routeSpeaker = false

    var localEarbuds = false
    var localSpeaker = true

//    var hearSet = HearSet([.earbuds])   // user options -- manually set
//    var route   = HearSet([])
//    var local   = HearSet([.speaker])   // this device's hardware route
    var reason  = "unknown reason"      // reason for change

    init() {

        listenForNotifications()
        updateRoute()
        Log("🎧 route earbuds:\(routeEarbuds) speaker:\(routeSpeaker)")
    }

    func listenForNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleRouteChange(_:)), name: NSNotification.Name.AVAudioSessionRouteChange, object: nil)
    }

    @objc func handleRouteChange(_ notification: Notification) {

        updateReason(notification)
        updateRoute()
        Log("🎧 \(#function) route earbuds:\(routeEarbuds) speaker:\(routeSpeaker) reason: \(reason)  ")
    }

    func updateReason(_ notification: Notification) {

        guard
            let userInfo = notification.userInfo,
            let reasonNum = userInfo[AVAudioSessionRouteChangeReasonKey] as? NSNumber,
            let reasonUint = AVAudioSessionRouteChangeReason(rawValue: reasonNum.uintValue)
            else { Log("🎧 unknown updateReason notification:\(notification)") ; return }
        
        switch reasonUint {
        case .oldDeviceUnavailable:     reason = "Unavailable "
        case .newDeviceAvailable:       reason = "New Device "
        case .routeConfigurationChange: reason = "Route change "
        case .categoryChange:           reason = "Category change "
        default:                        reason = "\(reasonUint)"
        }
    }

  
    func updateLocal(earBuds:Bool, speaker:Bool) {

        localEarbuds = earBuds ; localSpeaker = speaker

        if localEarbuds {

            if      earbuds  { routeEarbuds = true  ; routeSpeaker = false }
            else if speaker  { routeEarbuds = false ; routeSpeaker = true  }
            else             { routeEarbuds = false ; routeSpeaker = false }
        }
        else { // default speaker ///... ???

            if speaker  { routeEarbuds = false ; routeSpeaker = true }
            else        { routeEarbuds = false ; routeSpeaker = false }
        }
    }

    func updateRoute() {

        for output in AVAudioSession.sharedInstance().currentRoute.outputs {

            switch output.portType {

            case AVAudioSessionPortBluetoothA2DP,
                 AVAudioSessionPortBluetoothHFP,
                 AVAudioSessionPortBluetoothLE,
                 AVAudioSessionPortHeadphones:

                return updateLocal(earBuds: true, speaker: false)

            default: continue
            }
        }
        updateLocal(earBuds: false, speaker: true)
    }

    func canPlay() -> Bool {
        return (earbuds && localEarbuds) || (speaker && localSpeaker)
    }

    public func doHearAction(_ act: DoAction, _ value:Float) {

        let on = value > 0
        func updatePath(_ path:String) { TreeNodes.setOn(on, path, false) }

        switch act {
        case .hearSpeaker:  speaker = on ; updatePath("menu.more.hear.speaker")
        case .hearEarbuds:  earbuds = on ; updatePath("menu.more.hear.earbuds")
        default: return
        }
    }

 }
