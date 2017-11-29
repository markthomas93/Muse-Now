//
//  ParObj.swift
//  ParGraph
//
//  Created by warren on 7/30/17.
//  Copyright © 2017 Muse. All rights reserved.
//

import Foundation

@available(iOS 11,*)
@available(watchOS 4,*)

class ParObj {

    convenience init(_ str_: String) {

        self.init()
    }

    /// trace the status of a parse 
    func trace(_ node:Node!, _ nodeAny:NodeAny!, _ level:Int) {
         print ("*** \(#function): override me!")
    }
    /// Take snapshot. Used by parser to push state.
    func getSnapshot() -> Any! {
         print ("*** \(#function): override me!")
        return nil
    }
     /// Revert to snapshot. Used by parser to pop state.
    func putSnapshot(_ any:Any!) {
        print ("*** \(#function): override me!")
    }
    ///
    func isEmpty() -> Bool {
        print ("*** \(#function): override me!")
        return true
    }
    /// advance pointer to next position and return result of found match
    func advancePar(_ node:Node!, _ index:Int, _ str: String!,_ deltaTime:TimeInterval = 0) -> NodeAny! {
        print ("*** \(#function): override me!")
        return nil
    }

    /// match a quoted string and advance past match
    func matchMatchStr(_ node:Node!) -> NodeAny! {
        print ("*** \(#function): override me!")
        return nil
    }

    /// match a quoted string and advance past match
    func matchQuote(_ node:Node!, withEmpty:Bool=false) -> NodeAny! {
        print ("*** \(#function): override me!")
        return nil
    }

    /// match a regular expression and advance past match
    func matchRegx(_ node:Node!) -> NodeAny! {
        print ("*** \(#function): override me!")
        return nil
    }

}

