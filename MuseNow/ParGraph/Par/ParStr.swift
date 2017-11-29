//
//  ParStr.swift
//  ParGraph
//
//  Created by warren on 7/3/17.
//  Copyright © 2017 Muse. All rights reserved.
//

import Foundation

@available(iOS 11,*)
@available(watchOS 4,*)

/// Parse a substring `sub` of string `str`
class ParStr: ParObj {
    
    static var tracing = false
    
    var str = ""            /// original string
    var sub = Substring()   /// a substring of str, updated during parse

    convenience init(_ str_: String) {
        
        self.init()
        str = str_
        restart() // set sub from str
    }

    override func getSnapshot() -> Any! {
        return (sub)
    }
    override func putSnapshot(_ any:Any!) {
        if let any = any as? Substring {
            sub = any
        }
    }
    override func isEmpty() -> Bool {
        return sub.isEmpty
    }

    // restart sub(string) from beginning of str
    func restart() {
        sub = str[str.startIndex ..< str.endIndex]
    }
    func read(_ filename: String, _ ext:String) {
        if let url = Bundle.main.url(forResource: filename, withExtension: ext) {
            do {
                str = try String(contentsOf: url)
                restart()
            } catch {
                print("*** \(#function) error:\(error) loading contents of:\(url)")
            }
        }
        else {
            print("*** \(#function) file:\(filename).\(ext) not found")
        }
    }
    
    // advance past spaces
    func advance() {
        var count = 0;
        for char in sub {
            if " \t".contains(char) { count += 1 }
            else { break }
        }
        if count > 0 {
            sub = count < sub.count ? sub[ sub.index(sub.startIndex, offsetBy: count) ..< sub.endIndex] : Substring()
        }
    }
    /// Both matching and advancing range, for example:
    ///
    ///     '^\'([^\']+)\'' // matches inside, advance outside
    struct RangeRegx {
        var matching: Range<String.Index>
        var advance: Range<String.Index>
        init(_ matching_:NSRange, _ advance_:NSRange,_ str:String!) {
            matching = Range(matching_, in:str)!
            advance = Range(advance_, in:str)!
        }
    }
    /// Match regular expression to beginning of substring
    /// - parameter regx: compiled regular expression
    /// - returns: ranges of inner value and outer match, or nilZ
    func matchRegx(_ regx: NSRegularExpression) -> RangeRegx! {
        
        let nsRange = NSRange( sub.startIndex ..< sub.endIndex, in: str)
        let match = regx.matches(in: str, options:[], range:nsRange)
        if match.count == 0 { return nil }
        switch match[0].numberOfRanges {
        case 1:  return RangeRegx(match[0].range(at: 0), match[0].range(at: 0), str)
        default: return RangeRegx(match[0].range(at: 1), match[0].range(at: 0), str)
        }
    }

    /// compile a regular expression to be used later, during parse
    static func compile (_ pattern:String) -> NSRegularExpression! {
        
        let options : NSRegularExpression.Options = [
            //.caseInsensitive,
            //.allowCommentsAndWhitespace,
            //.ignoreMetacharacters,
            //.dotMatchesLineSeparators,
            //.anchorsMatchLines,
            .useUnixLineSeparators,
            .useUnicodeWordBoundaries]
        
        do { let regx = try NSRegularExpression(pattern: pattern, options:options)
            return regx
        }
        catch {
            print("*** Node(pat::) failed regx:\(pattern)")
            return nil
        }
    }

    //? match a regular expression and advance past match
    override func matchRegx(_ node:Node!) -> NodeAny! {

        if let regx = node.regx {

            if let rangeRegx = matchRegx(regx) {
                sub = rangeRegx.advance.upperBound < sub.endIndex
                    ? sub[ rangeRegx.advance.upperBound  ..< sub.endIndex ]
                    : Substring()
                advance()
                return NodeAny(node,String(str[rangeRegx.matching]))
            }
        }
        return nil
    }

    //? match a quoted string and advance past match
    override func matchQuote(_ node: Node!, withEmpty:Bool=false) -> NodeAny! {

        let pat = node.pattern

        if pat == "" { return withEmpty ? NodeAny(node,"") : nil }
        
        if pat.count <= sub.count,
            sub.hasPrefix(pat) {
            
            sub = pat.count < sub.count
                ? sub[ sub.index(sub.startIndex, offsetBy: pat.count) ..< sub.endIndex]
                : Substring()
            advance()
            return NodeAny(node,pat)
        }
        return nil
    }

   //? return result, when parStr.sub matches external function, if it exists 
    override func matchMatchStr(_ node:Node!) -> NodeAny! {
        // closure has already been set, so execute it
        if node.matchStr != nil,
            let ret = node.matchStr!(sub) {

            sub = ret.count < sub.count
                ? sub[ sub.index(sub.startIndex, offsetBy: ret.count) ..< sub.endIndex ]
                : Substring()
            advance()
            return NodeAny(node,ret)
        }
            // closure has not been set, so test name match
        else if let ret = matchQuote(node) {
            return NodeAny(node,ret)
        }
        return nil
    }

    func makeSlice(_ sub: Substring, del:String = "⦙", length:Int = 10) -> String {

         if sub.count <= 0 {
            return del.padding(toLength:length, withPad: " ", startingAt: 0) + del + " "
        }
        else {
            let endIndex = min(length,sub.count)
            let subEnd = sub.index(sub.startIndex, offsetBy: endIndex)
            let subStr = sub.count > 0 ? String(sub[sub.startIndex ..< subEnd]) : " "
            return del + subStr
                .replacingOccurrences(of: "\n", with: "↲")
                .padding(toLength:length, withPad: " ", startingAt: 0) + del + " "
        }
    }
    
    override func trace(_ node:Node!, _ nodeAny:NodeAny!, _ level:Int) {

        // ignore if not tracing
        if !ParStr.tracing { return }

        // indent predecessors based on level
        let pad = " ".padding(toLength: level*2, withPad: " ", startingAt: 0)

        // add a value if there is one
        var val = ""
        if let nodeAny = nodeAny {
            switch nodeAny.any {
            case let str as String: val = "-> \(str)".replacingOccurrences(of: "\n", with: "")
            default: break
            }
        }

        // print the result
        print(makeSlice(sub) + pad + node.pattern + ".\(node.id) \(node.reps.str()) \(val)")
    }
}

