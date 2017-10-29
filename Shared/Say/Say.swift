 
 import AVFoundation
 import Foundation
 
 /// type of phrase, will interrupt similar phrases
 enum SayType: Int { case
    blank = 0,
    direction,  // direction facing: future or past
    timeDow,    // day of week, while navigating dial
    timeEvent,  // time of current event while navigating
    timeMark,   // time for marked event during scann
    timeNow,    // time now
    timeDot,    // time of selected dot
    titleNow,   // title of current event
    titleEvent, // title of selected event while navigating
    titleMark,  // title of marked event during scan
    status,     // status of user action
    note,       // additional notes, reserved
    memo       // recorded audio memo
 }
 
 
 class Say : NSObject, AVSpeechSynthesizerDelegate, AVAudioPlayerDelegate {
    
    static let shared = Say()
    
    #if os(watchOS)
    let itemDuration = TimeInterval(1) // duration when not speaking
    #else
    let itemDuration = TimeInterval(2) // duration when not speaking
    #endif
    
    var actions = Actions.shared
    var dayHour = DayHour.shared
    
    var synth = AVSpeechSynthesizer.init()
    var audioPlayer: AVAudioPlayer!
    var audioSession = AVAudioSession.sharedInstance()
    var title = ""
    
    // settings
    var isSayOn = true
    var isSayTimeNow = true
    var isSayTimeMark = true
    var isSayTimeElapsed = true
    var isSayTimeDow = true
    var isSayTimeHour = true
    var isSayTimeEvent = true
    var isSaying  = false // status of utterance

    var sayVolume = Float(0.5)


    weak var sayTimer : Timer?
    weak var txtTimer : Timer?
    
    var sayCache = SayCache()
    var sayItem: SayItem?
    
    override init() {
        super.init()
        synth.delegate = self
     }
    
    func startPlaybackSession() { printLog("🗣 \(#function)")
        do {
            // AVAudioSessionCategoryPlayAndRecord will play back only small ear speaker
            //try audioSession.setCategory(AVAudioSessionCategoryPlayAndRecord, with: [.allowBluetoothA2DP,.interruptSpokenAudioAndMixWithOthers] )
            try audioSession.setCategory(AVAudioSessionCategoryPlayback, with: [.interruptSpokenAudioAndMixWithOthers] )
            sayTimer?.invalidate() //?? new
        }
        catch {  print("\(#function) Error:\(error)") }

    }
    func finishPlaybackSession() { printLog("🗣 \(#function)")
        if let audioPlayer = audioPlayer,
            audioPlayer.isPlaying {
                audioPlayer.stop()
        }
        do { try self.audioSession.setActive(false, with: .notifyOthersOnDeactivation) }
        catch { print("🗣\(#function) Error:\(error)")}
        actions.doSetTitle("")
    }
    
    func stopSay() {
        if synth.isSpeaking {
            cancelSpeech()
        }
        actions.doSetTitle("")
        sayCache.clearAll()
    }
    
    // speech to text volume
    public func doSpeakAction(_ act: DoAction) {
        switch act {
        case .speakOn:          isSayOn = true
        case .speakOff:         isSayOn = false
        case .speakLow:         isSayOn = true; sayVolume = 0.1
        case .speakMedium:      isSayOn = true; sayVolume = 0.5
        case .speakHigh:        isSayOn = true; sayVolume = 1.0
        default: break
        }
    }

  
    func clearAll() {  printLog("🗣 \(#function)")
        sayCache.clearAll()
        if isSayOn {
            synth.stopSpeaking(at: .immediate)
        }
        actions.doSetTitle("")
        finishPlaybackSession()
    }
    
    func clearTypes(_ types: [SayType]) {
        
        sayCache.clearTypes(types)
        
        if let sayingNow = sayItem {
            for type in types {
                if sayingNow.type == type {
                    clearTimers()
                    if isSayOn { synth.stopSpeaking(at: .immediate) }
                    else         { actions.doSetTitle("") }
                    return
                }
            }
        }
    }
    func clearTimers() {
        
        sayItem = nil
        sayTimer?.invalidate() ; sayTimer = nil
        txtTimer?.invalidate() ; txtTimer = nil
    }
    
    func cancelSpeech() {  printLog("🗣 \(#function)")
        
        clearTimers()
        actions.doSetTitle("")
        synth.stopSpeaking(at: .immediate)
        isSaying = false
        sayItem = nil
        finishPlaybackSession()
    }
    
    
    /**
     Update dialog based on new position on dial
     */
    func updateDialog(_ event: KoEvent!, type:SayType, spoken:String, title:String) -> Void {

        func newItem(_ delay: TimeInterval,_ decay: TimeInterval,_ clear:[SayType], immediate:Bool = false) {

            if immediate {
                actions.doSetTitle(title)
            }
            if type == .blank {
                clearAll()
            }
            else if clear.count > 0 {
                clearTypes(clear)
            }
            let item = SayItem(event, type, delay, decay, spoken, title)
            sayCache.updateCache(item)
            updateSpeech()
        }
        let never = Double.greatestFiniteMagnitude

        switch type {
        case .blank:      newItem(0.00, 0.05, [], immediate: true)
        case .memo:       newItem(0.04, 0.5, [.timeDot,    .timeEvent, .timeMark, .timeNow])
        case .timeDow:    newItem(0.01, never, []) // sleep on it
        case .timeNow:    newItem(0.02, 4.0, [.timeDot,    .timeEvent, .timeMark])
        case .timeEvent:  newItem(1.00, 4.0, [.timeDot,    .timeMark,  .timeNow])
        case .timeMark:   newItem(0.03, 4.0, [.timeDot,    .timeEvent, .timeNow])
        case .timeDot:    newItem(2.01, 4.0, [.timeNow,    .timeEvent])
            
        case .titleEvent: newItem(0.50, 1.0, [.titleNow,   .titleMark])
        case .titleMark:  newItem(0.01, 1.0, [.titleNow,   .titleMark])
        case .titleNow:   newItem(0.01, 8.0, [.titleEvent, .titleMark])
            
        case .direction:  newItem(0.05, never,[])
        case .status:     newItem(0.01, 8.0, [])
        case .note:       newItem(4.01, 8.0, [])
        }
    }
    
    func updateSpeech() {
        
        if sayItem != nil {
            return
        }
        else if let item = sayCache.popNext() {
            sayPhrase(item)
        }
        else {
            isSaying = false
            do {
                if let item = sayCache.getNext() {
                    
                    let timeNow = Date().timeIntervalSince1970
                    let deltaTime = max(0.01, item.delay - timeNow)
                    if deltaTime < 0.2 {
                        isSaying = true
                       
                    }
                    else {
                        try audioSession.setActive(false, with: .notifyOthersOnDeactivation)
                    }
                    // item.log("say timer > \(String(format:"%.2f",deltaTime)) ")
                    sayTimer = Timer.scheduledTimer(withTimeInterval: deltaTime, repeats: false, block: {_ in
                        self.clearTimers()
                        self.updateSpeech()
                    })
                }
                else {
                    actions.doSetTitle("")
                }
            }
            catch {
                
            }
        }
    }

    func playRecording(_ item:SayItem) {

        let url = FileManager.documentUrlFile(item.spoken)
        #if os(iOS)
            if item.title == "Memo" {
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
        playSound(url: url, item.title)
    }
    
    func sayPhrase(_ item: SayItem) {
        
        // item.log("say phrase >>>")
        
        clearTimers()
        sayItem = item
        isSaying = true
        actions.doSetTitle(item.title)
        
        if item.type == .memo {
            playRecording(item)
        }
        else if item.spoken != "" {

            if isSayOn {
                func playLocal() { synth.speak(UtterItem(item, sayVolume))}
                func playRemote() { }
                Hear.shared.hearVia.play(playLocal, playRemote)
            }
            else { // for non-speech mode, clear out title after a scene
                txtTimer = Timer.scheduledTimer(withTimeInterval: 2 , repeats: false, block: {_ in
                    //self.actions.doSetTitle("")
                    self.clearTimers()
                    self.updateSpeech()
                })
            }
        }
    }
    
    // AVSpeechSynthesizerDelegate ---------------------------------
    
    // When finished, clear title, and setup next in line
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        
        let utter = utterance as! UtterItem
        utter.item?.log( "<<< finish")
        actions.doSetTitle("")
        clearTimers()
        updateSpeech()
    }
    
    // When finished, clear title, and setup next in line
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        
        let utter = utterance as! UtterItem
        utter.item?.log( "<<< cancel")
        actions.doSetTitle("")
        clearTimers()
        updateSpeech()
    }
    
    // AVAudioPlayerDelegate --------------------------------------------
    
    func playSound(url: URL, _ title: String) {

        func playLocal() {

            isSaying = true
            startPlaybackSession()

            do {
                audioPlayer = try AVAudioPlayer(contentsOf: url)
                audioPlayer.setVolume(1.0, fadeDuration: 0.1)
                audioPlayer.delegate = self
                audioPlayer.play()
            }
            catch {
                printLog("\(#function) error")
                isSaying = false
            }
        }

        func playRemote() {
        }

        clearTimers()
        actions.doSetTitle(title)
        synth.stopSpeaking(at: .immediate)
        Hear.shared.hearVia.play(playLocal,playRemote)
      }
 }
