 
 import AVFoundation
 import Foundation
 
 /// type of phrase, will interrupt similar phrases
 enum SayPhrase: Int { case
    phraseBlank = 0,
    phraseDirection,  // direction facing: future or past
    phraseDayOfWeek,  // day of week, while navigating dial
    phraseEventTime,  // time of current event while navigating
    phraseTimeNow,    // time now
    phraseDotTime,    // time of selected dot
    phraseEventTitle, // title of selected event while navigating
    phraseSlider,     // status of user action on slider
    phraseMemo        // recorded audio memo
 }
 
 struct SaySet: OptionSet {
    let rawValue: Int
    static let sayMemo    = SaySet(rawValue: 1 << 0)
    static let sayEvent   = SaySet(rawValue: 1 << 1)
    static let saySpeech  = SaySet(rawValue: 1 << 2)
    static let sayTime    = SaySet(rawValue: 1 << 3)
    static let size       = 4
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

    var saySet = SaySet([.sayMemo, .sayEvent, .sayTime])

    var sayVolume = Float(0.5)

    weak var sayTimer : Timer?
    weak var txtTimer : Timer?
    
    var sayCache = SayCache()
    var sayItem: SayItem?
    var sayItemBlank = SayItem()
    
    override init() {
        super.init()
        synth.delegate = self
        do { try audioSession.setCategory(AVAudioSessionCategorySoloAmbient, with: [.allowBluetoothA2DP,.interruptSpokenAudioAndMixWithOthers] )}
        catch {  print("\(#function) Error:\(error)") }
        }

    // speech to text volume
    public func doSayAction(_ act: DoAction, isSender: Bool) {

        switch act {
        case .saySpeechOn:  saySet.insert(.saySpeech)
        case .saySpeechOff: saySet.remove(.saySpeech)
        case .sayMemoOn:    saySet.insert(.sayMemo)
        case .sayMemoOff:   saySet.remove(.sayMemo)

        case .speakLow:     saySet.insert(.saySpeech) ; sayVolume = 0.1
        case .speakMedium:  saySet.insert(.saySpeech) ; sayVolume = 0.5
        case .speakHigh:    saySet.insert(.saySpeech) ; sayVolume = 1.0
        default: break
        }
        if isSender {
            Session.shared.sendMsg(["class"  : "SaySet",
                                    "putSet" : saySet.rawValue])
        }
    }
    func updateSetFromSession(_ saySet_:SaySet) {
        saySet = saySet_
    }


    func getMenus() -> [StrAct] {

        var strActs = [StrAct]()
        strActs.append(saySet.contains(.saySpeech) ? StrAct("mute speech" , .saySpeechOff) : StrAct("speak" ,    .saySpeechOn))
        strActs.append(saySet.contains(.sayMemo)   ? StrAct("mute memo"   , .sayMemoOff)   : StrAct("play memos", .sayMemoOn))
        return strActs
     }

     func clearAll() {  printLog("🗣 \(#function)")
        cancelSpeech()
        sayCache.clearAll()
    }
    
    func clearPhrases(_ phrases: [SayPhrase]) {
        
        sayCache.clearPhrases(phrases)
        
        if let sayingNow = sayItem {
            for phrase in phrases {
                if sayingNow.phrase == phrase {
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
    func updateDialog(_ event: MuEvent!,_ phrase:SayPhrase, spoken:String, title:String) -> Void { printLog("🗣 \(#function) \(event?.title ?? "") .\(phrase)")

        func newItem(_ delay: TimeInterval,_ decay: TimeInterval,_ clear:[SayPhrase], immediate:Bool = false) {

            if immediate                { actions.doSetTitle(title) }

            if phrase == .phraseBlank   { clearAll() }
            else if clear.count > 0     { clearPhrases(clear) }

            let item = SayItem(event, phrase, delay, decay, spoken, title)
            sayCache.updateCache(item)
            updateSpeech()
        }

        let never = Double.greatestFiniteMagnitude // sleep on it

        switch phrase {
        case .phraseBlank:      newItem(0.00,  0.05, [], immediate: true)
        case .phraseMemo:       newItem(0.04,  0.50, [.phraseEventTitle, .phraseEventTime, .phraseDotTime, .phraseTimeNow])
        case .phraseDayOfWeek:  newItem(0.01, never, [.phraseDirection])
        case .phraseTimeNow:    newItem(0.02,  4.00, [.phraseDotTime,    .phraseEventTime,   .phraseDirection])
        case .phraseEventTime:  newItem(1.00,  4.00, [.phraseEventTime,  .phraseDotTime,     .phraseTimeNow])
        case .phraseEventTitle: newItem(0.03,  2.00, [.phraseEventTitle, .phraseEventTime])
        case .phraseDotTime:    newItem(2.01,  4.00, [.phraseDotTime,    .phraseTimeNow,     .phraseEventTime])
        case .phraseDirection:  newItem(0.05, never, [])
        case .phraseSlider:     newItem(0.01,  8.00, [])
        }
    }

    /**
     Set timer to execute item based on its delay time
     */
    func nextItem(_ item:SayItem) {

        printLog("🗣 \(#function) getNext event:\(item.event?.title ?? "nil") phrase:\(item.phrase)")
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

    func updateSpeech() {
        if sayItem != nil { return  printLog("🗣 \(#function) sayItem != nil ") }
        else if let item = sayCache.popNext() { doItem(item) }
        else if let item = sayCache.getNext() { nextItem(item) }
        else { printLog("🗣 \(#function) continue") }
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

        if item.phrase == .phraseMemo && playMemo(item) {}
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
