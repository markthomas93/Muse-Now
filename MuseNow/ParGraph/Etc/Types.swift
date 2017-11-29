//
//  Types.swift
//  ParGraph
//
//  Created by warren on 7/3/17.
//  Copyright © 2017 Muse. All rights reserved.
//

import Foundation

@available(iOS 11,*)
@available(watchOS 4,*)


typealias VoidVoid  = () -> Void
typealias VoidAny   = () -> Any?
typealias VoidBool  = () -> Bool
typealias VoidNodeAny = () -> NodeAny!
typealias BoolVoid  = (_ ret:Bool) -> Void
typealias NodeAnyVoid = (_ nodeAny: NodeAny) -> Void
typealias SubAny    = (_ str:Substring) -> Any?
typealias SubStr = (_ str:Substring) -> String?


typealias ParObjNodeAny = (_ parObj:ParObj, _ level:Int) -> NodeAny!
