 
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
    static let memo    = SaySet(rawValue: 1 << 0)
    static let event   = SaySet(rawValue: 1 << 1)
    static let time    = SaySet(rawValue: 1 << 2)
    static let size    = 3
    
 }

 class Say : NSObject, AVSpeechSynthesizerDelegate {
    
    static let shared = Say()

    var saySet = SaySet([.event, .time])
    var sayVolume = Float(1.0)

    #if os(watchOS)
    let itemDuration = TimeInterval(2) // duration when not speaking
    #else
    let itemDuration = TimeInterval(2) // duration when not speaking
    #endif
    
    var actions = Actions.shared
    var dayHour = DayHour.shared
    
    var synth = AVSpeechSynthesizer()
    var audioPlayer: AVAudioPlayer!
    var audioSession = AVAudioSession.sharedInstance()
    var title = ""


    weak var sayTimer : Timer?
    weak var txtTimer : Timer?
    
    var sayCache = SayCache()
    var sayItem: SayItem!
    var isSaying = false
    
    override init() {
        super.init()
        synth.delegate = self
        do { try audioSession.setCategory(AVAudioSessionCategorySoloAmbient, with: [.allowBluetoothA2DP,.interruptSpokenAudioAndMixWithOthers] )}
        catch {  print("\(#function) Error:\(error)") }
    }

    // speech to text volume
    public func doSayAction(_ act: DoAction, isSender: Bool) {

        switch act {
        case .sayMemo:    saySet.insert(.memo)
        case .skipMemo:   saySet.remove(.memo)

        case .sayTime:    saySet.insert(.time)
        case .skipTime:   saySet.remove(.time)

        case .sayEvent:    saySet.insert(.event)
        case .skipEvent:   saySet.remove(.event)

        case .speakLow:     sayVolume = 0.1
        case .speakMedium:  sayVolume = 0.5
        case .speakHigh:    sayVolume = 1.0
        default: break
        }
        Settings.shared.settingsFromMemory()
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
        //strActs.append(saySet.contains(.speech) ? StrAct("skip speech"  , .skipSpeech) : StrAct("say speech", .saySpeech))
        strActs.append(saySet.contains(.memo)   ? StrAct("skip memos"   , .skipMemo)   : StrAct("say memos",  .sayMemo))
        strActs.append(saySet.contains(.event)  ? StrAct("skip events"  , .skipEvent)  : StrAct("say events", .sayEvent))
        strActs.append(saySet.contains(.time)   ? StrAct("skip times"   , .skipTime)   : StrAct("say times",   .sayTime))
        return strActs
    }

    func clearAll() {  printLog("🗣 \(#function)")
        cancelSpeech() // clears timers
        Audio.shared.finishPlaybackSession()
        sayCache.clearAll()
        sayItem = nil
    }


    func clearSayItem() {

        clearTimers()
        if sayItem.phrase == .phraseMemo {
            Audio.shared.finishPlaybackSession()
        }
        else if saySet.rawValue > 0 {
            synth.stopSpeaking(at: .immediate)
        }
        else {
            actions.doSetTitle("")
        }
        sayItem = nil
    }
      /**
     Some SayItems will kick out other say times, like a day change kicking out a "past" "future". SayItem
     So, clear out the kicked items. And cancel current sayItem if it is one of those items.
     */
    func clearPhrases(_ phrases: [SayPhrase]) {
        
        sayCache.clearPhrases(phrases)
        
        if sayItem != nil {
            for phrase in phrases {
                if sayItem.phrase == phrase {
                    return clearSayItem()
                }
            }
        }
    }
    /**
     Some SayItems persist foreever, until a value has changed.
     So, only remove all the other phrases, with a decay time that is less than infinity.
     */
    func clearTransientPhrases() {
        sayCache.clearTransientPhrases()
        if sayItem != nil {
            clearSayItem()
        }
    }

    func clearTimers() {

        sayTimer?.invalidate() ; sayTimer = nil
        txtTimer?.invalidate() ; txtTimer = nil
    }

    func cancelSpeech() {

        clearTimers()
        clearTransientPhrases()
        isSaying = false ; printLog("🗣 \(#function) isSaying:\(self.isSaying) 🚦")
    }
    
    
    /**
     Update dialog based on new position on dial
     */
    func updateDialog(_ event: MuEvent!,_ phrase:SayPhrase, spoken:String, title:String, via:String) -> Void {

/**
  - note: delay time > 1 sec is useful for user spinning dial,
         for .phraseDotTime and .phraseEventTime
         but adds confusion for scanning where a pending cache may use delay times to
  */
        func newItem(_ delay: TimeInterval,_ decay: TimeInterval,_ clear:[SayPhrase], immediate:Bool = false) {
            if immediate                { actions.doSetTitle(title) }
            if phrase == .phraseBlank   { clearTransientPhrases() }
            else if clear.count > 0     { clearPhrases(clear) }
            sayCache.updateCache(SayItem(event, phrase, delay, decay, spoken, title))
            updateSpeech(via:#function)
        }

        // begin ------------------------------------------------

        printLog("🗣 updateDialog(via:\(via)) \"\((event?.title ?? "").trunc(length:20))\" .\(phrase)")

        switch phrase {
        case .phraseBlank:      newItem(0.00,  0.05, [.phraseBlank], immediate: true)
        case .phraseMemo:       newItem(0.00,  0.50, [.phraseBlank])
        case .phraseDayOfWeek:  newItem(0.01,  Infi, [.phraseDirection])
        case .phraseTimeNow:    newItem(0.00,  Infi, [.phraseDotTime, .phraseEventTime, .phraseDirection])
        case .phraseEventTime:  newItem(0.02,  4.00, [.phraseDotTime, .phraseTimeNow])
        case .phraseEventTitle: newItem(0.01,  2.00, [.phraseEventTime])
        case .phraseDotTime:    newItem(2.00,  4.00, [.phraseTimeNow, .phraseEventTime])
        case .phraseDirection:  newItem(0.05,  Infi, [])
        case .phraseSlider:     newItem(0.10,  0.20, [])
        }
    }

    func updateSpeech(via:String) {
        printLog("🗣 updateSpeech(via:\(via))")
        // text, speed, and memos will clear sayItem when done
        if sayItem == nil {
            if      let item = sayCache.popNext() { return execItem(item) }
            else if let item = sayCache.getNext() { return waitItem(item) }
            else { isSaying = false ; printLog("🗣 updateSpeech(via:\(via) isSaying:\(isSaying)  🚦") }
        }
    }

    /**
     Set timer to execute item based on its delay time
     */
    func waitItem(_ item:SayItem) {

        let deltaTime = max(0.01, item.delay - Date().timeIntervalSince1970)
        if deltaTime > 0.20 {
            try? audioSession.setActive(false, with: .notifyOthersOnDeactivation)
        }
        else if deltaTime < 1.0 {
            isSaying = true
        }
        printLog("🗣 \(#function) wait:\(deltaTime) \(item.shortTitle()) .\(item.phrase) \(isSaying ? "🚦" : "")")

        // item.log("say timer > \(String(format:"%.2f",deltaTime)) ")
        sayTimer = Timer.scheduledTimer(withTimeInterval: deltaTime, repeats: false, block: {_ in
            printLog("🗣 \(#function) fired! \(item.shortTitle()) .\(item.phrase)")
            self.clearTimers()
            self.updateSpeech(via:#function)
        })
    }


    func execItem(_ item: SayItem) {

        isSaying = true ; printLog("🗣 \(#function)  \(item.shortTitle()) .\(item.phrase) isSaying:\(self.isSaying) 🛑")

        clearTimers()
        actions.doSetTitle(item.title)
        sayItem = item

        func txtLocal() {
            txtTimer?.invalidate()
            txtTimer = nil
            printLog("🗣 \(#function) before  \(itemDuration) ⏱ anim:\(Anim.shared.animNow)" )
            txtTimer = Timer.scheduledTimer(withTimeInterval: itemDuration, repeats: false, block: {_ in
                printLog("🗣 \(#function) timeout  \(item.shortTitle()) .\(item.phrase)  ⏱ anim:\(Anim.shared.animNow)")
                self.clearTimers()
                self.sayItem = nil
                self.actions.doSetTitle("")
                self.updateSpeech(via:#function)
            })
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

        func playMemo(_ item: SayItem) {

            Transcribe.shared.transcribe(item) // transcribe item if

            if Say.shared.saySet.contains(.memo) && Hear.shared.canPlay() {
                self.synth.stopSpeaking(at: .immediate) //?? remove?
                let url = FileManager.documentUrlFile(item.spoken)
                Audio.shared.playUrl(url: url) { finished in
                    self.sayItem = nil
                    self.updateSpeech(via: #function)
                }
            }
        }

        // begin ----------------------------

        if item.phrase == .phraseMemo { playMemo(item) }
        else if saySet.rawValue > 1 && playSay(item) {}
        else { txtLocal() }
    }

    // AVSpeechSynthesizerDelegate ---------------------------------
    
    // When finished, clear title, and setup next in line
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) { printLog("🗣 speechSynthesizer didFinish ")

        //let utter = utterance as! UtterItem ; utter.item?.log( "<<< finish")

        actions.doSetTitle("")
        clearTimers()
        sayItem = nil
        updateSpeech(via:#function)
    }
    
    // When finished, clear title, and setup next in line
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) { printLog("🗣 speechSynthesizer <<< cancel >>>")
        
        // let utter = utterance as! UtterItem ; utter.item?.log( "<<< cancel")
        actions.doSetTitle("")
        clearTimers()
        sayItem = nil
        updateSpeech(via:#function)
    }
    
 }
