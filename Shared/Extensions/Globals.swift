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
    
    "⟳", // life cycle
    "✺", // complication

    "👆", // tap action
    "🎧", // headphones
    "🗣", // Say
    "∿": // audio recorder

        print(KoDate.getHourMinSecMsec() + ": " + str)
        
    case

    "⊛", // crown
    "✓", // actions
    "⎚", // scene animation
    "⚆", // wheel spoke animation
    "↔︎", // session activation state
    "←", // session receiving
    "→", // session sending

    "⧉", // sync files

    "⊕", // motion
    "𐆄", // execute closure during animation pause
    "⿳", // menu
    "🎞", // texture
    "⚇", // dot
    "✏", // Transcribe
    "⧉": // sync files

        break

    default: break
    }

}

