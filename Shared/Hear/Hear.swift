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

    func parseMsg(_ msg: [String : Any])  {

        if let _ = msg["put"] {
            if let on = msg["earbuds"] as? Bool { earbuds = on ; TreeNodes.shared.setValue(on, forKey: "hear.earbuds")}
            if let on = msg["speaker"] as? Bool { speaker = on ; TreeNodes.shared.setValue(on, forKey: "hear.spearker")}
            #if os(iOS)
            PagesVC.shared.menuVC.tableView.reloadData()
            #endif
        }

        if let _ = msg["get"] { // TODO: Not called, updated via TreeNodes file?
            Session.shared.sendMsg(["class" : "Hear",
                                    "put" : "yo",
                                    "earbuds" : earbuds,
                                    "speaker" : speaker])
        }
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
    
    
    public func doHearAction(_ act: DoAction, _ value:Float,_ isSender:Bool) {

        let on = value > 0

        func updateClass(_ className:String, _ path:String) {
            TreeNodes.setOn(on,path)
            Actions.shared.doRefresh(/*isSender*/false)
            if isSender {
                Session.shared.sendMsg(["class" : className, path : on])
            }
        }
        
        switch act {
        case .hearSpeaker:  speaker = on ; updateClass("Hear","menu.more.hear.speaker")
        case .hearEarbuds:  earbuds = on ; updateClass("Hear","menu.more.hear.earbuds")
        default: break
        }
    }

 }
