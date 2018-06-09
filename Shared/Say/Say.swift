 
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

  class Say : NSObject, AVSpeechSynthesizerDelegate, DemoBackupDelegate {
    
    static let shared = Say()

    // model

    var memo = true
    var event = true
    var time = true
    var volume = Float(0.5)

    // runtime

    let itemDuration = TimeInterval(2) // duration when not speaking
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


    // DemoBackupDelegate --------------------------

    var backup: Say!

    func setFrom(_ from:Any) {
        if let from = from as? Say {
            memo    = from.memo
            event   = from.event
            time    = from.time
            volume  = from.volume
        }
    }

    func setupBackup() {
        backup = Say()
        backup.setFrom(self)
    }
    func setupBeforeDemo() {
        setupBackup()
        memo    = false
        event   = false
        time    = false
        volume  = 1.0
    }
    func restoreAfterDemo() {
        if let backup = backup {
            setFrom(backup)
        }
    }

    // session messages -----------------

    func parseMsg(_ msg: [String : Any])  {

        if let _ = msg["get"] {
        }
        else {
            if let on = msg["memo"]  as? Bool { memo = on  ; TreeNodes.shared.setValue(on, forKey: "say.memo") }
            if let on = msg["time"]  as? Bool { time = on  ; TreeNodes.shared.setValue(on, forKey: "say.time") }
            if let on = msg["event"] as? Bool { event = on ; TreeNodes.shared.setValue(on, forKey: "say.event") }

            #if os(iOS)
            PagesVC.shared.menuVC.tableView.reloadData()
            #endif
        }
    }

    //
    public func doSayAction(_ act: DoAction, _ value: Float) {

        let on = value > 0
        func updatePath(_ path:String) { TreeNodes.setOn(on, path, false) }

        switch act {
        case .sayMemo:  memo  = on ; updatePath("menu.more.say.memo")
        case .sayTime:  time  = on ; updatePath("menu.more.say.time")
        case .sayEvent: event = on ; updatePath("menu.more.say.event")

        case .speakLow:     volume = 0.1
        case .speakMedium:  volume = 0.5
        case .speakHigh:    volume = 1.0
        default: break
        }
    }


    func clearAll() {  Log("🗣 \(#function)")
        clearTimers()
        clearTransientPhrases()
        isSaying = false
        Audio.shared.finishPlaybackSession()
        sayCache.clearAll()
        sayItem = nil
    }


    func clearSayItem() { Log("🗣 \(#function)")

        clearTimers()
        if sayItem.phrase == .phraseMemo {
            Audio.shared.finishPlaybackSession()
        }
        else if memo || event || time {
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

        sayTimer?.invalidate()
        txtTimer?.invalidate()
    }

     func cancelSpeech() {  Log("🗣 \(#function)")
        clearTimers()
        clearTransientPhrases()
        isSaying = false
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
            updateSpeech(via:"newItem")
        }

        // begin ------------------------------------------------

        Log("🗣 updateDialog via:\(via) \"\((event?.title ?? "").trunc(length:20))\" .\(phrase)")

        switch phrase {
        case .phraseBlank:      newItem(0.00,  0.05, [.phraseBlank], immediate: true)
        case .phraseMemo:       newItem(0.00,  0.50, [.phraseBlank])
        case .phraseDayOfWeek:  newItem(0.01,  Infi, [.phraseDirection])
        case .phraseTimeNow:    newItem(0.00,  Infi, [.phraseDotTime, .phraseEventTime, .phraseDirection])
        case .phraseEventTime:  newItem(0.02,  4.00, [.phraseDotTime])
        case .phraseEventTitle: newItem(0.01,  2.00, [.phraseEventTime])
        case .phraseDotTime:    newItem(2.00,  4.00, [.phraseTimeNow, .phraseEventTime])
        case .phraseDirection:  newItem(0.05,  Infi, [])
        case .phraseSlider:     newItem(0.10,  0.20, [])
        }
    }

    func updateSpeech(via:String) {

        func log(_ symbol:String) { Log("🗣 updateSpeech(\(via)) \(sayItem?.shortTitle() ?? "")" + symbol) }

        // text, speed, and memos will clear sayItem when done
        if sayItem != nil                     { log("continue") }
        else if let item = sayCache.popNext() { execItem(item) }
        else if let item = sayCache.getNext() { waitItem(item) }
        else                                  { log("finished") ; isSaying = false  }
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
        Log("🗣 \(#function) wait:\(deltaTime) \(item.shortTitle()) .\(item.phrase) isSaying:\(isSaying)")

        // item.log("say timer > \(String(format:"%.2f",deltaTime)) ")
        sayTimer = Timer.scheduledTimer(withTimeInterval: deltaTime, repeats: false, block: {_ in
            Log("🗣 \(#function) fired! \(item.shortTitle()) .\(item.phrase)")
            self.clearTimers()
            self.updateSpeech(via:"waitItem sayTimer")
        })
    }


    func execItem(_ item: SayItem) {  Log("🗣 \(#function)  \(item.shortTitle()) .\(item.phrase))")

        isSaying = true

        clearTimers()
        actions.doSetTitle(item.title)
        sayItem = item
        let say = Say.shared
        let hear = Hear.shared

        func playMemo() -> Bool {

            if sayItem.phrase != .phraseMemo { return false }

            Transcribe.shared.appleTranscribeEvent(sayItem.event) {} // transcribe item if no already

            if say.memo && hear.canPlay() { Log("🗣 \(#function) \(sayItem.title)")
                //?? self.synth.stopSpeaking(at: .immediate) //?? remove?
                let url = FileManager.documentUrlFile(sayItem.spoken)
                Audio.shared.playUrl(url: url) { finished in
                    playMemoDone()
                }
            }
            return true
        }

        func playMemoDone() {
            if sayItem.phrase == .phraseMemo {
                sayItem = nil
            }
            self.updateSpeech(via:"playMemo")
        }
        func playSay() -> Bool {

            if !say.event,!say.time { return false }

            if sayItem.spoken != "" && hear.canPlay() { Log("🗣 \(#function) \(sayItem.title)")

                self.clearTimers()
                synth.speak(UtterItem(sayItem, volume))
                return true
            }
            return false
        }
        func playText() { Log("🗣 \(#function) \(sayItem.title)")

            txtTimer?.invalidate()
            txtTimer = Timer.scheduledTimer(withTimeInterval: itemDuration, repeats: false, block: {_ in
                self.clearTimers()
                self.sayItem = nil
                self.actions.doSetTitle("")
                self.updateSpeech(via:"execItem txtTimer")
            })
        }

        // begin ----------------------------

        if      playMemo() {}
        else if playSay() {}
        else { playText() }
    }

    // AVSpeechSynthesizerDelegate ---------------------------------
    
    /**
    When finished speaking, clear title, and setup next in line
     */
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        Log("🗣 speechSynthesizer <<< didFinish >>>") // (utterance as! UtterItem)?.log( "<<< finish")

        actions.doSetTitle("")
        clearTimers()
        if sayItem?.phrase != .phraseMemo { sayItem = nil }
        updateSpeech(via:"<<< didFinish >>>")
    }
    
    /**
     After cancelled speaking, clear title, and setup next in line
     */
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        Log("🗣 speechSynthesizer <<< cancel >>>")// utterance as! UtterItem)?.log( "<<< cancel")

        actions.doSetTitle("")
        clearTimers()
        if sayItem?.phrase != .phraseMemo { sayItem = nil }
        updateSpeech(via:"<<< cancel >>>")
    }
    
 }
