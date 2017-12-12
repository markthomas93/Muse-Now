 
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
        Settings.shared.updateArchive()
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
        cancelSpeech()
        sayCache.clearAll()
    }
    
    func clearPhrases(_ phrases: [SayPhrase]) {
        
        sayCache.clearPhrases(phrases)
        
        if let sayingNow = sayItem {
            for phrase in phrases {
                if sayingNow.phrase == phrase {
                    clearTimers()
                    if saySet.rawValue > 0 {
                        synth.stopSpeaking(at: .immediate)
                        isSaying = false ; printLog("🗣 \(#function) isSaying:\(self.isSaying)")
                    }
                    else { actions.doSetTitle("") }
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
        isSaying = false ; printLog("🗣 \(#function) isSaying:\(self.isSaying)")
        Audio.shared.finishPlaybackSession()
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
        case .phraseSlider:     newItem(0.10,  0.20, [.phraseSlider])
        }
    }

    /**
     Set timer to execute item based on its delay time
     */
    func waitItem(_ item:SayItem) { //  printLog("🗣 \(#function) getNext event:\(item.event?.title ?? "nil") phrase:\(item.phrase)")

         let deltaTime = max(0.01, item.delay - Date().timeIntervalSince1970)
        if deltaTime < 0.2 {
            isSaying = true ; printLog("🗣 \(#function) isSaying:\(self.isSaying)")
        }
        else {
            do {try audioSession.setActive(false, with: .notifyOthersOnDeactivation)}
            catch{}
        }

        // item.log("say timer > \(String(format:"%.2f",deltaTime)) ")
        sayTimer = Timer.scheduledTimer(withTimeInterval: deltaTime, repeats: false, block: {_ in
            self.clearTimers()
            self.sayItem = nil
            self.updateSpeech()
        })
    }

    func updateSpeech() {

        if      let item = sayCache.popNext() { execItem(item) }
        else if let item = sayCache.getNext() { waitItem(item) }
        else                                  { isSaying = false }
        printLog("🗣 \(#function) isSaying:\(isSaying)")
    }

    func playMemo(_ item: SayItem) -> Bool {

        transcribe(item) // transcribe item if

        if Say.shared.saySet.contains(.memo) && Hear.shared.canPlay() {
            self.synth.stopSpeaking(at: .immediate) //?? remove?
            let url = FileManager.documentUrlFile(item.spoken)
            if !Audio.shared.playUrl(url: url) {
                self.sayItem = nil
                self.isSaying = false ; printLog("🗣 \(#function) isSaying:\(self.isSaying)")
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

    func execItem(_ item: SayItem) { //printLog("🗣 \(#function) sayItem:\(item.title)" )

        clearTimers()
        actions.doSetTitle(item.title)
        sayItem = item
        isSaying = true

        func txtLocal() {
            txtTimer?.invalidate()
            txtTimer = Timer.scheduledTimer(withTimeInterval: itemDuration, repeats: false, block: {_ in
               printLog("🗣 \(#function) timeout \"\(self.sayItem?.title ?? "")\"")
                self.clearTimers()
                self.sayItem = nil
                self.actions.doSetTitle("")
                self.updateSpeech()
            })
        }

        if item.phrase == .phraseMemo && playMemo(item) {}
        else if saySet.rawValue > 1 && playSay(item) {}
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
        updateSpeech()
    }
    
    // When finished, clear title, and setup next in line
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) { printLog("🗣 speechSynthesizer <<< cancel >>>")
        
        // let utter = utterance as! UtterItem ; utter.item?.log( "<<< cancel")
        actions.doSetTitle("")
    }
    
 }
