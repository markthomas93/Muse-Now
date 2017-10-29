import UIKit
import AVFoundation

class SayItem: NSObject {
    
    var event: KoEvent!
    var type = SayType.blank
    var delay = TimeInterval(0)
    var decay = TimeInterval(0)
    var spoken  = ""
    var title   = ""
    
    convenience init (_ event_: KoEvent!, _ type_: SayType, _ delay_:TimeInterval, _ decay_:TimeInterval, _ spoken_:String, _ title_:String) {
        self.init()
        event  = event_
        type   = type_

        let timeNow = Date().timeIntervalSince1970
        delay  = timeNow + delay_      // equatable
        decay  = timeNow + decay_

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
        return String(format:"%7.3f ",t-Active.lifeTime)
    }
    
    
    func log(_ str: String) {

        func dump() -> String {
            
            let rDelay = "\(relative(delay)) "
            let rDecay = "\(relative(decay)) "
            let typeStr = "\(type)".padding(toLength: 11, withPad: " ", startingAt: 0)
            let output = typeStr + rDelay + rDecay + spoken + " | " + title
            return output
        }
       
//        let leftStr = str.padding(toLength: 26, withPad: " ", startingAt: 0)
//        print("🗣 \(relative(Date().timeIntervalSince1970)) \(leftStr) \(dump())")
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
