//  Anim+Closure.swift


import Foundation

class Closure {

    var title = ""
    var closure: (()->())? = nil
    init(_ title_: String,_ closure_: @escaping ()->() ) {
        title = title_
        closure = closure_
    }
}

extension Anim {
    
    /**
    While animating, defer execution of closures that may stutter visuals.
     - note: During multiple file updates, so eliminiate duplicate doRefresh requests.
    */
    func addClosure(title:String, _ closure_:@escaping ()->()) {

        // eliminate duplicat requests
        for closure in closures {
            if closure.title == title {
                return // duplicate found
            }
        }
        let closure = Closure(title,closure_)

        switch animNow {
            
        case .futrPause,
             .pastPause,
             .pastMark,
             .futrMark: execClosure(closure) // no need to wait while pausing
            
        default:        closures.append(closure)
        /**/            Log("𐆄 \(#function)")
        }
    }

    func setRecordingClosure(_ closure_:@escaping ()->()) {
        closures.removeAll()
        closures.append(Closure("recording", closure_))
    }

    func execClosure(_ closure: Closure) { Log("𐆄 \(#function)(\(closure.title)")
        closure.closure?()
    }
    
    /// during pause in animation, execute closures FIFO
    func execClosures() {
        
         while closures.count > 0 {
            
            let closure = closures.removeFirst()
            execClosure(closure)
        }
    }
}
