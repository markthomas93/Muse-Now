 
 import AVFoundation
 import Foundation
 
 /// type of phrase, will interrupt similar phrases
 enum SayType: Int { case
    sayBlank = 0,
    sayDirection,  // direction facing: future or past
    sayDayOfWeek,  // day of week, while navigating dial
    sayEventTime,  // time of current event while navigating
    sayTimeNow,    // time now
    sayDotTime,    // time of selected dot
    sayEventTitle, // title of selected event while navigating
    saySlider,     // status of user action on slider
    sayMemo        // recorded audio memo
 }
 
 struct SaySet: OptionSet {
    let rawValue: Int
    static let sayMemo          = SaySet(rawValue: 1 << 0)
    static let saySpeech        = SaySet(rawValue: 1 << 1)

    static let sayTimeNow       = SaySet(rawValue: 1 << 2)
    static let sayTimeUntil     = SaySet(rawValue: 1 << 3)
    static let sayDayOfWeek     = SaySet(rawValue: 1 << 4)
    static let sayTimeHour      = SaySet(rawValue: 1 << 5)
    static let sayEventTime     = SaySet(rawValue: 1 << 6)

    static let size             = 7

 }

 class Say : NSObject, AVSpeechSynthesizerDelegate {
    
    static let shared = Say()
    
    #if os(watchOS)
    let itemDuration = TimeInterval(1) // duration when not speaking
    #else
    let itemDuration = TimeInterval(2) // duration when not speaking
    #endif
    
    var actions = Actions.shared
    var dayHour = DayHour.shared
    
    var synth = AVSpeechSynthesizer()
    var audioPlayer: AVAudioPlayer!
    var audioSession = AVAudioSession.sharedInstance()
    var title = ""

    var saySet = SaySet([.sayMemo,          .sayTimeNow,
                         .sayTimeUntil,   .sayDayOfWeek,
                         .sayTimeHour,      .sayEventTime])

    var sayVolume = Float(0.5)

    weak var sayTimer : Timer?
    weak var txtTimer : Timer?
    
    var sayCache = SayCache()
    var sayItem: SayItem?
    var sayItemBlank = SayItem()
    
    override init() {
        super.init()
        synth.delegate = self
        synth.outputChannels = []

//        let audioSession = AVAudioSession.sharedInstance()
//        do {
//
//            try! audioSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
//            try audioSession.setMode(AVAudioSessionModeSpokenAudio)
//            try audioSession.setActive(true, with: .notifyOthersOnDeactivation)
//
//            let currentRoute = AVAudioSession.sharedInstance().currentRoute
//            for description in currentRoute.outputs {
//                if description.portType == AVAudioSessionPortHeadphones {
//                    try audioSession.overrideOutputAudioPort(AVAudioSessionPortOverride.none)
//                    print("headphone plugged in")
//                } else {
//                    print("headphone pulled out")
//                    try audioSession.overrideOutputAudioPort(AVAudioSessionPortOverride.speaker)
//                }
//            }
//
//        } catch {
//            print("audioSession properties weren't set because of an error.")
//        }

     }

    // speech to text volume
    public func doSpeakAction(_ act: DoAction) {
        switch act {
        case .speakOn:          saySet.insert(.saySpeech)
        case .speakOff:         saySet.remove(.saySpeech)
        case .speakLow:         saySet.insert(.saySpeech) ; sayVolume = 0.1
        case .speakMedium:      saySet.insert(.saySpeech) ; sayVolume = 0.5
        case .speakHigh:        saySet.insert(.saySpeech) ; sayVolume = 1.0
        default: break
        }
    }

    func updateSaySetFromSession(_ saySet_:SaySet) {
        saySet = saySet_
    }
    func clearAll() {  printLog("🗣 \(#function)")
        cancelSpeech()
        sayCache.clearAll()
    }
    
    func clearTypes(_ types: [SayType]) {
        
        sayCache.clearTypes(types)
        
        if let sayingNow = sayItem {
            for type in types {
                if sayingNow.type == type {
                    clearTimers()
                    if saySet.contains(.saySpeech) { synth.stopSpeaking(at: .immediate) }
                    else       { actions.doSetTitle("") }
                    return
                }
            }
        }
    }
    func clearTimers() {

        sayTimer?.invalidate() ; sayTimer = nil
        txtTimer?.invalidate() ; txtTimer = nil
    }

     func cancelSpeech() {  printLog("🗣 \(#function)")
        clearTimers()
        actions.doSetTitle("")
        synth.stopSpeaking(at: .immediate)
        Audio.shared.finishPlaybackSession()
        sayItem = nil
    }
    
    
    /**
     Update dialog based on new position on dial
     */
    func updateDialog(_ event: MuEvent!, type:SayType, spoken:String, title:String) -> Void { printLog("🗣 \(#function) \(event?.title ?? "") .\(type)")

        func newItem(_ delay: TimeInterval,_ decay: TimeInterval,_ clear:[SayType], immediate:Bool = false) {

            if immediate {
                actions.doSetTitle(title)
            }
            if type == .sayBlank {
                clearAll()
            }
            else if clear.count > 0 {
                clearTypes(clear)
            }
            let item = SayItem(event, type, delay, decay, spoken, title)
            sayCache.updateCache(item)
            updateSpeech()
        }

        let never = Double.greatestFiniteMagnitude // sleep on it

        switch type {
        case .sayBlank:      newItem(0.00,  0.05, [], immediate: true)
        case .sayMemo:       newItem(0.04,  0.50, [.sayEventTitle, .sayEventTime, .sayDotTime, .sayTimeNow])
        case .sayDayOfWeek:  newItem(0.01, never, [.sayDirection])
        case .sayTimeNow:    newItem(0.02,  4.00, [.sayDotTime,    .sayEventTime,   .sayDirection])
        case .sayEventTime:  newItem(1.00,  4.00, [.sayEventTime,  .sayDotTime,     .sayTimeNow])
        case .sayEventTitle: newItem(0.03,  2.00, [.sayEventTitle, .sayEventTime])
        case .sayDotTime:    newItem(2.01,  4.00, [.sayDotTime,    .sayTimeNow,     .sayEventTime])
        case .sayDirection:  newItem(0.05, never, [])
        case .saySlider:     newItem(0.01,  8.00, [])
        }
    }
    
    func updateSpeech() {

        if sayItem != nil {
             printLog("🗣 \(#function) sayItem != nil ")
            return
        }
        else if let item = sayCache.popNext(wiggleRoom: 0.0) {

            doItem(item)
        }
        else if let item = sayCache.getNext() {
            printLog("🗣 \(#function) getNext event:\(item.event?.title ?? "nil") type:\(item.type)")
            let timeNow = Date().timeIntervalSince1970
            let deltaTime = max(0.01, item.delay - timeNow)
            sayItem = sayItemBlank
            if deltaTime > 0.2 {
                do  { try audioSession.setActive(false, with: .notifyOthersOnDeactivation) } catch {}
            }
            // item.log("say timer > \(String(format:"%.2f",deltaTime)) ")
            sayTimer = Timer.scheduledTimer(withTimeInterval: deltaTime, repeats: false, block: {_ in
                self.clearTimers()
                self.sayItem = nil
                self.updateSpeech()
            })
        }
        else {
             printLog("🗣 \(#function) continue")
        }
    }


    func playMemo(_ item: SayItem) -> Bool {

        transcribe(item) // transcribe item if

        if Say.shared.saySet.contains(.sayMemo) && Hear.shared.canPlay() {
            self.synth.stopSpeaking(at: .immediate) //?? remove?
            let url = FileManager.documentUrlFile(item.spoken)
            if !Audio.shared.playUrl(url: url) {
                self.sayItem = nil
            }
            return true
        }
        return false
    }
    func playSay(_ item: SayItem) -> Bool {

        if item.spoken != "" && Hear.shared.canPlay() {
             printLog("🗣 \(#function) sayItem:\(item.title)" )
            self.clearTimers()
            synth.speak(UtterItem(item, sayVolume))
            return true
        }
        return false
    }

    func doItem(_ item: SayItem) { printLog("🗣 \(#function) sayItem:\(item.title)" )

        clearTimers()
        actions.doSetTitle(item.title)
        sayItem = item

        func txtLocal() {
            txtTimer?.invalidate()
            txtTimer = Timer.scheduledTimer(withTimeInterval: itemDuration, repeats: false, block: {_ in
                 printLog("🗣 \(#function) timeout")
                self.clearTimers()
                self.sayItem = nil
                self.actions.doSetTitle("")
                self.updateSpeech()
            })
        }

        if item.type == .sayMemo && playMemo(item) {}
        else if saySet.contains(.saySpeech) && playSay(item) {}
        else { txtLocal() }
    }

    func transcribe(_ item:SayItem) {
        #if os(iOS)
            if item.title == "Memo" {
                 let url = FileManager.documentUrlFile(item.spoken)
                Transcribe.shared.appleSttUrl(url) { found in
                    if let str = found.str,
                        str != "",
                        let event = item.event {
                        event.sttApple = found.str
                        event.title = found.str
                        Actions.shared.doUpdateEvent(event, isSender: true)
                    }
                }
            }
        #endif
    }

    // AVSpeechSynthesizerDelegate ---------------------------------
    
    // When finished, clear title, and setup next in line
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) { printLog("🗣 speechSynthesizer didFinish ")

        //let utter = utterance as! UtterItem ; utter.item?.log( "<<< finish")

        actions.doSetTitle("")
        clearTimers()
        sayItem = nil
        self.updateSpeech()

    }
    
    // When finished, clear title, and setup next in line
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) { printLog("🗣 speechSynthesizer <<< cancel >>>")
        
        // let utter = utterance as! UtterItem ; utter.item?.log( "<<< cancel")
        actions.doSetTitle("")
    }
    
 }
