//
//  TouchScreen.swift
//  MuseNow
//
//  Created by warren on 1/2/18.
//  Copyright © 2018 Muse. All rights reserved.
//

import Foundation
import UIKit


/**
 Full screen rediction of touches. Useful for guided tour where
 touching screen can progress to next explanation bubble, and
 during authoring, help setup timing of each bubble.
 - note: uses extension to UIWindow
 */

class TouchScreen {

    static var shared = TouchScreen()

    var startTime: TimeInterval!
    var timeOut = TimeInterval(60) // maximum time to redirect, unless refreshed startTime
    var touching = false

    typealias CallTouch = (Set<UITouch>,UIEvent?)->()

    var began: CallTouch?
    var moved: CallTouch?
    var ended: CallTouch?


    func redirectSendEvent(_ event:UIEvent) -> Bool {

        if  startTime == 0 ||
            began == nil ||
            Date().timeIntervalSince1970 - startTime > timeOut {
            return false
        }

        if let touches = event.allTouches {
            for touch in touches.enumerated() {
                switch touch.element.phase {
                case .began: began?(touches,event) ; touching = true
                case .moved: moved?(touches,event)
                case .stationary: print("*** stationary ***")
                case .ended,
                     .cancelled: ended?(touches,event); touching = false
                }
                break
            }
        }
        return true
    }

    /**
     Setup redirection, with at least began for TouchesBegan, with optional moved and ended.
     Because an interruption could lock out screen, there is a 60 second timeout.
     So, need to call continue redirecting before time has expired.
     */
    func redirect(began began_:CallTouch!,moved moved_:CallTouch!=nil,ended ended_:CallTouch!=nil) {
        began = began_
        moved = moved_
        ended = ended_
        startTime = Date().timeIntervalSince1970
    }
    /**
     Test that startTime has not expired and redirect installed
     */
    func canTouch(_ call:CallTouch?,_ touches: Set<UITouch>,_ event: UIEvent?) -> Bool {
        if  startTime == 0 ||
            began == nil ||
            Date().timeIntervalSince1970 - startTime > timeOut {

            return false
        }
        call?(touches,event)
        return true
    }
    /**
     reset the 1 minute clock
     */
    func continueRedirecting() {
        if startTime == 0    { print("cannot redirect before setting up redirect(:::)") }
        else if began == nil { print("after endRedirecting, must setup redirect(:::), again") }
        else                 { startTime = Date().timeIntervalSince1970 }
    }
    /**
     stop redirecting for now, but keep closures for later
     */
    func suspendRedirecting() {
        startTime = 0
    }

    /**
    stop redirecting permanently and release closures to save memory
     */
    func endRedirecting() {
        startTime = 0
        began = nil
        moved = nil
        ended = nil
    }

    func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) -> Bool { return canTouch(began,touches,event) }
    func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) -> Bool { return canTouch(moved,touches,event) }
    func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) -> Bool { return canTouch(ended,touches,event) }
    func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) -> Bool { return canTouch(ended,touches,event) }
}

// used for TouchScreen class, below

extension UIWindow {
    override open func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !TouchScreen.shared.touchesBegan(touches,with: event) {
            super.touchesBegan(touches, with: event)
        }
    }
    override open func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !TouchScreen.shared.touchesMoved(touches,with: event) {
            super.touchesMoved(touches, with: event)
        }
    }
    override open func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !TouchScreen.shared.touchesEnded(touches,with: event) {
            super.touchesEnded(touches, with: event)
        }
    }
    override open func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !TouchScreen.shared.touchesCancelled(touches,with: event) {
            super.touchesCancelled(touches, with: event)
        }
    }
}

