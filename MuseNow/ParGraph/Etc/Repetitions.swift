//
//  Repetitions.swift
//  ParGraph
//
//  Created by warren on 7/3/17.
//  Copyright © 2017 Muse. All rights reserved.


import Foundation

@available(iOS 11,*)
@available(watchOS 4,*)

class Repetitions {
    
    enum Count : String { case
        one   = ".",  // {1,1} exactly one
        opt   = "?",  // {0,1} zero or one
        any   = "*",  // {0,MaxReps} one or more
        many  = "+",  // {1,MaxReps} one or more
        range = "{}"  // {m,n} from m to n // reserved for later
    }
    var surf  = false // floating position,
    var count = Count.one // repetitions of after edges
    var repMin = 1  // minimum repetitions
    var repMax = 1  // maximum repetitions
    var isExplicit = false // was explicitly declared, otherwise default value
    
    init(_ count_:Count = .one) {
        updateCount(count_)
    }
    
    func updateCount(_ count_:Count) {
        count = count_
        
        switch count {
        case .one:    repMin = 1 ; repMax = 1               //         {1,1}
        case .opt:    repMin = 0 ; repMax = 1               // ?       {0,1}
        case .any:    repMin = 0 ; repMax = Edge.MaxReps    // *       {0,}
        case .many:   repMin = 1 ; repMax = Edge.MaxReps    // +       {1,}
        case .range:  repMin = 1 ; repMax = 1               // {m,n}   {m,n}        ...
        }
    }

    func parse(_ input: String) {
        isExplicit = true
        for char in input.substring(to: 1) {
            switch char {
            case ".": updateCount(.one)
            case "?": updateCount(.opt)
            case "*": updateCount(.any)
            case "+": updateCount(.many)
            case "~": surf = true
            default: updateCount(.range) ; isExplicit = false
            }
        }
    }
    
    func str() -> String  {
        var ret = ""
        switch count {
        case .range: ret = "{\(repMin),\(repMax)}"
        case .one:  break
        default:     ret =  count.rawValue
        }
        if surf {
            ret += "~"
        }
        return ret
    }
    
}

