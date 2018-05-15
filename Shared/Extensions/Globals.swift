//  Globals.swift

import UIKit

let bordColor = UIColor(red: 0.25, green: 0.25, blue: 0.25, alpha: 1.0) // section cell border color
let headColor = UIColor(red: 0.15, green: 0.15, blue: 0.15, alpha: 1.0) // section cell color
let cellColor = UIColor(red: 0.08, green: 0.08, blue: 0.08, alpha: 1.0) // standard cell color
let textColor = UIColor(red: 0.85, green: 0.85, blue: 0.85, alpha: 1.0) // textcolor inside cell

let Phi⁻¹ = CGFloat(0.618033989)
let Phi⁻² = CGFloat(0.3819660116)
let Phi⁻³ = CGFloat(0.2360679778)
let Phi⁻⁴ = CGFloat(0.145898034)

let Pi = Double.pi
let Pi2 = Double.pi*2 // Swift 3.1 deprecated M_PI, but has problem with CGFloat.pi
let Infi = Double.greatestFiniteMagnitude // infinity

func delay(_ delay:Double,_ closure:@escaping ()->()) {
    let when = DispatchTime.now() + delay
    DispatchQueue.main.asyncAfter(deadline: when, execute: closure)
}

func Log(_ block:@escaping (()->(String))) {
    assert(DebugLog(block()))
}

func Log(_ str: String) {
    assert(DebugLog(str))
}

func DebugLog(_ str: String) -> Bool {

    switch str.substring(to: 1) {

    case
    "⌚︎", // watch application state
    "👆", // tap action
    "⟳", // life cycle
    "▤": // TreeTableView
        
        print(MuDate.getHourMinSecMsec() + ": " + str)

    case
    "✺",  // background task
    "⊛", // crown
    "⚇", // dot

    "∿",  // audio recorder
    "←", // session receiving
    "↔︎", // session activation state
    "→", // session sending
    "✏", // Transcribe

    "⧉",  // syncfile
    "⊕",  // motion
    "🗣", // Say TTS
    "🔈", // Audio

    "⟳", // life cycle

    "💬", // bubble animation closure
    "⿴", // windows covers for speech bubble

    "𐂷", // tree cell
    "⚡️", // startup
    "⧉", // syncfile

    "🎧", // Hear Via
    "🔰", // onboarding pages (japanese beginnner symbol)

    "▭", // textfield

    "*", // TableVC updates
    "⏲", // timing


    "⿳", // calendar event
    "✏︎", // draw bubble
    "📅", // EkNotification

    "⎚", // scene animationync files

    "⌘", // doAction

    "🗣", // Say TTS
    "🔈", // Audio

    "▣", // observe main window bounds
    "◰", // view layout

    "𝓡", // routine

    "✓", // actions
    "⎚", // scene animation
    "⚆", // wheel spoke animation

    "𐆄", // execute closure during animation pause
    "🎞": // texture

        break
        
    default: break
    }
    return true
}

