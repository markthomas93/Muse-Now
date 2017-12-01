//  Globals.swift

import UIKit


let headColor = UIColor(red: 0.15, green: 0.15, blue: 0.15, alpha: 1.0)
let cellColor = UIColor(red: 0.08, green: 0.08, blue: 0.08, alpha: 1.0)
let textColor = UIColor(red: 0.85, green: 0.85, blue: 0.85, alpha: 1.0)

let Phi⁻¹ = CGFloat(0.618033989)
let Phi⁻² = CGFloat(0.3819660116)
let Phi⁻³ = CGFloat(0.2360679778)
let Phi⁻⁴ = CGFloat(0.145898034)

let Pi = Double.pi
let Pi2 = Double.pi*2 // Swift 3.1 deprecated M_PI, but has problem with CGFloat.pi

func printLog(_ str: String) {
    
    switch str.substring(to: 1) {
        
    //case NSLog(str)

    case
    "▤", // TreeTableView
    "⧉", // sync files
    "⌘", // doAction
    "▭", // textfield
    "✺", // complication
    "⿳", // menu

     "📅", // EkNotification
    "🔈", // Audio

    "🎧", // Hear Via
    "∿": // audio recorder

        print(MuDate.getHourMinSecMsec() + ": " + str)
        
    case
    "←", // session receiving
    "↔︎", // session activation state
    "→", // session sending

    "𐂷", // tree cell
    "𝓡", // routine
    "🗣", // Say TTS
    "⟳", // life cycle
    "👆", // tap action
    "⊛", // crown
    "✓", // actions
    "⎚", // scene animation
    "⚆", // wheel spoke animation

    "⊕", // motion
    "𐆄", // execute closure during animation pause
    "⿳", // menu
    "🎞", // texture
    "⚇", // dot
    "✏": // Transcribe


        break

    default: break
    }

}

