//  Hear.swift
//  Klio
//
//  Created by warren on 10/20/17.
//  Copyright © 2017 Muse. All rights reserved.

import Foundation
import AVFoundation

class Hear {

    static let shared = Hear()

    // allowed output via

    var hearVia = HearVia([.earbuds,.remote])

    enum Route: String { case
        unknown = "unknown",
        speaker = "speaker",
        earbuds = "earbuds",
        remote  = "remote"
    }

    var route   = Route.unknown    // earbuds, speaker, remote phone
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
        printLog("🎧 route: \(route) port: \(port) reason: \(reason)  ")
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
     Determine route from state if both devices

     self    | remote   -> result
     earbuds | *        -> earbuds
     speaker | earbuds  -> remote
     speaker | !earbuds -> speaker
     */
    func updateFromRemote(_ remote: String) {

        let oldRoute = route
        let newRoute = getRoute()
        switch remote {
        case Route.earbuds.rawValue: route = (newRoute == .earbuds ? newRoute : .remote)
        default: route = newRoute
        }
        printLog("🎧 \(#function)(\(remote) (\(oldRoute),\(newRoute)) ⟶ \(route)")
    }

    func updateRoute() {

         route = getRoute()

        // always send route .earbuds to other device, which
        // should change other device's route to "remote
        // except for weird edge case, where it also has earbuds.

        Session.shared.sendMsg( ["class" : "hear",
                                 "route" : route.rawValue])
    }

    func getRoute() -> Route {

        for output in AVAudioSession.sharedInstance().currentRoute.outputs {

            switch output.portType {

            case AVAudioSessionPortBluetoothA2DP,
                 AVAudioSessionPortBluetoothHFP,
                 AVAudioSessionPortBluetoothLE,
                 AVAudioSessionPortHeadphones:

                return .earbuds

            default: continue
            }
        }
        return .speaker 
    }

    /**
     Get status from other device
     */
    func updateRemote() {
        Session.shared.sendMsg( ["class" : "hear",
                                 "route" : "get"])
    }



 }
