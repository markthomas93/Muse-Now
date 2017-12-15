import UIKit
import AVFoundation

class SayItem: NSObject {
    
    var event: MuEvent!
    var phrase = SayPhrase.phraseBlank
    var delay = TimeInterval(0)
    var decay = TimeInterval(0)
    var spoken  = ""
    var title   = ""

    
    convenience init (_ event_: MuEvent!, _ phrase_: SayPhrase, _ delay_:TimeInterval, _ decay_:TimeInterval, _ spoken_:String, _ title_:String) {
        self.init()
        event  = event_
        phrase = phrase_

        let timeNow = Date().timeIntervalSince1970
        delay  = timeNow + delay_      // equatable
        decay  = decay_ == Infi ? Infi : timeNow + decay_

        spoken = spoken_
        title  = title_
    }

    static func == (lhs: SayItem, rhs: SayItem) -> Bool {
        return (lhs.delay == rhs.delay && lhs.spoken == rhs.spoken)
    }
    
    static func <= (lhs: SayItem, rhs: SayItem) -> Bool {
        return (lhs.delay <= rhs.delay)
    }
    
    func relative(_ t:TimeInterval) -> String {
        let delta = t-Active.lifeTime
        return String(format:"%7.3f ", min(88888888,delta))
    }
    

    func shortTitle () -> String {
         return "\"\((event?.title ?? "").trunc(length:20))\""
    }
    func log(_ str: String) {

        func dump() -> String {
            
            let rDelay = "\(relative(delay)) "
            let rDecay = "\(relative(decay)) "
            let phraseStr = "\(phrase)".padding(toLength: 11, withPad: " ", startingAt: 0)
            let output = phraseStr + rDelay + rDecay + spoken + " | " + title
            return output
        }
       
//        let leftStr = str.padding(toLength: 26, withPad: " ", startingAt: 0)
//        Log("🗣 \(relative(Date().timeIntervalSince1970)) \(leftStr) \(dump())")
    }
    
}

class UtterItem: AVSpeechUtterance {
    var item : SayItem!
    convenience init (_ item_:SayItem,_ volume_:Float) {
        self.init(string:item_.spoken)
        item = item_
        volume = volume_
    }
}
