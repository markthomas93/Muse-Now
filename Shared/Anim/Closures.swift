//  Anim+Closure.swift


import Foundation

class ClosureItem {

    var title = ""
    var closure: CallVoid? = nil
    var ignore = false // if duplicate
    init(_ title_: String,_ closure_: @escaping CallVoid ) {
        title = title_
        closure = closure_
    }
}

class Closures {

    static let shared = Closures()

    var closures = [ClosureItem]()
    
    /**
     While animating, defer execution of closures that may stutter visuals.
     - note: During multiple file updates, so eliminiate duplicate refresh requests.
     */
    func clearClosuresWith(_ with:String) {

        // ignore prior duplicate requests
        for closure in closures {
            if closure.title.contains(with) {
                closure.ignore = true
            }
        }
    }
    /**
     While animating, defer execution of closures that may stutter visuals.
     - note: During multiple file updates, so eliminiate duplicate refresh requests.
     */
    func addClosure(title:String, anytime:Bool = false, _ closure_:@escaping CallVoid) { Log("𐆄 addClosure(\(title))")

        // find duplicate a duplicate
        for closure in closures {
            if closure.ignore { continue }
            if closure.title == title {
                if anytime {  return } // can execute anywhere, so keep this one
                closure.ignore = true  // other wise ignore this one and add later one at bottom
            }
        }
        let closure = ClosureItem(title,closure_)
        closures.append(closure)
    }

    func execClosure(_ closure: ClosureItem) { Log("𐆄 execClosure(\(closure.title))")
        closure.closure?()
    }
    
    /// during pause in animation, execute closures FIFO
    func execClosures() {
        
         while closures.count > 0 {
            
            let closure = closures.removeFirst()
            if !closure.ignore {
                execClosure(closure)
            }
        }
    }
}
