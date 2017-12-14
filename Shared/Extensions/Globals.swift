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
let Infi = Double.greatestFiniteMagnitude // infinity

func delay(_ delay:Double, closure:@escaping ()->()) {
    let when = DispatchTime.now() + delay
    DispatchQueue.main.asyncAfter(deadline: when, execute: closure)
}
extension String {
    /**
     Truncates the string to the specified length number of characters and appends an optional trailing string if longer.
     - Parameter length: Desired maximum lengths of a string
     - Parameter trailing: A 'String' that will be appended after the truncation.

     - Returns: 'String' object.
     */
    func trunc(length: Int, trailing: String = "…") -> String {
        return (self.count > length) ? self.prefix(length) + trailing : self
    }
}
func printLog(_ str: String) {
    
    switch str.substring(to: 1) {
        
    //case NSLog(str)

    case

    "⧉", // sync files
    "📅", // EkNotification
     "⌘", // doAction

    "←", // session receiving
    "↔︎", // session activation state
    "→": // session sending

        print(MuDate.getHourMinSecMsec() + ": " + str)
        
    case


    "🗣", // Say TTS
    "🔈", // Audio
    "🎧", // Hear Via
    "∿",  // audio recorder

     "⟳", // life cycle
    "▣", // observe main window bounds
    "◰", // view layout
    "⊛", // crown
    "▤", // TreeTableView

    "▭", // textfield
    "⿳", // menu

    "👆", // tap action

    "✺", // complication
    "𐂷", // tree cell
    "𝓡", // routine

    "✓", // actions
    "⎚", // scene animation
    "⚆", // wheel spoke animation

    "⊕", // motion
    "𐆄", // execute closure during animation pause
    "🎞", // texture
    "⚇", // dot
    "✏": // Transcribe
        break
    default: break
    }

}

