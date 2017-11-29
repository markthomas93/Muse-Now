//  Muse+Test.swift
//  Created by warren on 9/3/17.
//  Copyright © 2017 Muse. All rights reserved.

import Foundation

extension Muse {

    func testScript() {

        print(divider())
        root.printGraph()
        
        let script = root.makeScript()
        print(divider() + script)
        let match = Par.shared.parStr.compare(Substring(script))
        print(divider())
        let parWords = ParWords("whatever")

        func printRequest(_ request:String, timeNow: TimeInterval = Date().timeIntervalSince1970) {

            print("\"\(request)\" ⟶ ", terminator:"")

            parWords.update(request,timeNow)

            if let nodeAny = root.findStrand(parWords, 0) {
                print(nodeAny.anyStr(flat:true) + " ⟵ hops:\(parWords.totalHops())")
            }
            else  {
                print(" *** failed ***")
            }
        }

        func events(_ str:Substring) -> String! {
            let ret =  str.hasPrefix("yo") ? "yo" : nil
            return ret
        }

        ParStr.tracing = false

        printRequest("muse show all alarms")
        printRequest("muse show alarms")
        printRequest("muse please show alarms")

        printRequest("muse show event yo")
        root.setMatch("muse show event events()") { str in return events(str) }
        printRequest("muse show event yo")

        printRequest("muse event show yo")
        printRequest("yo muse show event")
        printRequest("muse show yo event")
        printRequest("muse event yo show")

        printRequest("muse show event yo")
        printRequest("muse hide yo")    // should hide yo event
        printRequest("muse hide event")
        printRequest("hide event")
        printRequest("hide")
    }
    func testDeclare() {

        // explicit declaration of muse ----------------------

        #if false
            root.printGraph(Visitor(0))
            let msg1 = ParStr("muse show all alarms")
            root.go(msg1) { found in print (msg1.str + " -> \(found.str())")  }

            let msg2 = ParStr("muse show keyword matching yo")
            root.go(msg2) { found in print (msg2.str + " -> \(found.str())") }
            // Node.tracing = true

            root.setMatch("muse show type match matches") { str in return matches(str) }
            msg2.restart()
            root.go(msg2) { found in print(msg2.str + " -> \(found.str())") }

            let msg3 = ParStr("muse show keyword matching Oy")
            root.go(msg3) { found in print (msg3.str + " -> \(found.str())") }
        #endif
    }

}
