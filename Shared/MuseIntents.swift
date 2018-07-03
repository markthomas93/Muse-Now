//
//  File.swift
//  MuseNow
//
//  Created by warren on 7/2/18.
//  Copyright © 2018 Muse. All rights reserved.
//

import Foundation
import Intents

class MuseIntents {

    static var shared = MuseIntents()

    func intentStr(_ intent: DotIntent) -> String {
        var str = ""
        if let action = intent.action?.first?.displayString {
            str += action
        }
        if let item = intent.item?.first?.displayString {
            str += " " + item
        }
        return str
    }

    func donateStartupIntent() {

        let intent = DotIntent()
        intent.action = [INObject(identifier: "now", display: "now")]
        intent.item   = []
        let interaction = INInteraction(intent: intent, response: nil)
        interaction.donate { error in
            if error != nil { print ("\(#function) error:\(error!)") }
            else            { print ("\(#function) intent: " + self.intentStr(intent)) }
        }
        donateMenuIntents()
    }

    func donateMenuIntents() {

        for action in ["show", "hide"] {
            for item in ["events", "memos", "routine"] {
                let intent = DotIntent()
                intent.action = [INObject(identifier: action, display: action)]
                intent.item   = [INObject(identifier: item,   display: item)]

                let interaction = INInteraction(intent: intent, response: nil)
                interaction.donate { error in
                    if error != nil { print ("\(#function) error:\(error!)") }
                    else            { print ("\(#function) intent: " + self.intentStr(intent)) }
                }
            }
        }
    }
}
