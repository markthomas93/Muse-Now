//  Muse.par.swift
//  ParGraph
//
//  Created by warren on 7/3/17.
//  Copyright © 2017 Muse. All rights reserved.

import Foundation

@available(iOS 11,*)
@available(watchOS 4,*)


class Muse {

    static var shared = Muse()
    var root: Node!
    var contexualStrings =  ["muse", "now", "clear", "show", "hide", "all", "calendar", "memos", "marks"]
    let found = MuseFound()
    let parWords = ParWords("whatever")

    init() {

        root = Par.shared.parse("Muse", "par")

    }


    /**
     Parse string and find match to muse graph
     - parameter str: lowercase string
     - returns: -1: not found. 0...n: number of hops from ideal graph
     */
    func findMatch(_ str: String) -> MuseFound {

        let timeNow = Date().timeIntervalSince1970
        parWords.update(str,timeNow)
        found.str = str
        found.nodeAny = root.findStrand(parWords, 0)
        found.hops = found.nodeAny != nil ? parWords.totalHops() : -1
        return found
    }

    func parseNodeAny(_ nodeAny:NodeAny,_ model: MuseModel,_ visitor:Visitor = Visitor(0)) {

        if let node = nodeAny.node, !visitor.newVisit(node.id) { return }
        
        let any = nodeAny.any
        switch any {
        case let nodeAnys as [NodeAny]:
            for nodeAny in nodeAnys {
                parseNodeAny(nodeAny, model,visitor)
            }

        case let nodeAny as NodeAny:  parseNodeAny(nodeAny, model)
        case let str as String:
            switch str {
            case "show": model.show = true
            case "hide": model.show = false
            default: break
            }
        default: break
        }
    }

    func execModel(_ mode:MuseModel) {
    }

    func execFound(_ found: MuseFound,_ event:MuEvent! = nil) {

        if found.str.hasPrefix("muse") {
            let model = MuseModel()
            parseNodeAny(found.nodeAny, model)
            execModel(model)
        }
    }

    func resultStr(_ found: MuseFound) -> String {

        switch found.hops {
        case -1: return " *** failed ⟵ hops:\(found.hops)"
        default: return found.nodeAny?.anyStr(flat:true) ?? "??" + " ⟵ hops:\(found.hops)"
        }
    }

}

