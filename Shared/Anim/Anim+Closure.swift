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
    
    /// while animating, defer execution of closures that may stutter visuals
    func addClosure(title:String, _ closure_:@escaping ()->()) {
        let closure = Closure(title,closure_)
        switch animNow {
            
        case .futrPause,
             .pastPause,
             .pastMark,
             .futrMark: execClosure(closure)
            
        default:        closures.append(closure)
        
        /**/            printLog("𐆄 \(#function)")
        }
    }

    func setRecordingClosure(_ closure_:@escaping ()->()) {
        closures.removeAll()
        closures.append(Closure("recording", closure_))
    }

    func execClosure(_ closure: Closure) { printLog("𐆄 \(#function)(\(closure.title)")
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
