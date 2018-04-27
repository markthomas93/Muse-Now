
import WatchKit
import UIKit
import AVFoundation
import CoreAudio

class Record: NSObject, CLLocationManagerDelegate {

    static let shared = Record()

    let audioSession = AVAudioSession.sharedInstance()
    var audioRecorder: AVAudioRecorder?

    let recDur = TimeInterval(30) // recording duration
    var recBgnTime = TimeInterval(0)
    var recEndTime = TimeInterval(0)
    var abortTime = TimeInterval(0)
    var recName = ""
    var groupURL: URL?
    var audioTimer = Timer() // audio note timer

    let recordSettings = [
        
        AVSampleRateKey : NSNumber(value: Float(16000.0)),
        AVFormatIDKey : NSNumber(value:Int32(kAudioFormatMPEG4AAC)),
        AVNumberOfChannelsKey : NSNumber(value: Int32(1)),
        AVEncoderAudioQualityKey : NSNumber(value: Int32(AVAudioQuality.medium.rawValue))]

    func isRecording() -> Bool {
        return recEndTime < recBgnTime
    }


    // Audio -----------------------------------

    let waitingPeriod = TimeInterval(2.0)
    let minimumDuration = TimeInterval(1.0)

    func recordAfterInterruption() -> Bool {
        let deltaEnd = Date().timeIntervalSince1970 - recEndTime
        let lastDur = recEndTime - recBgnTime // last duration < 1 was aborted

        if deltaEnd < waitingPeriod,
            lastDur < minimumDuration {
            toggleRecordAction()
            return true
        }
        return false
    }
    func recordAfterWaitingPeriod() {

        if isRecording() {
            Log("∿ \(#function) isRecording")
            toggleRecordAction()
        }
        else {

            let deltaEnd = Date().timeIntervalSince1970 - recEndTime

            Log(String(format:"∿ \(#function) delta:%.2f dur:%.2f",deltaEnd, recEndTime - recBgnTime))

            if deltaEnd > waitingPeriod {
                toggleRecordAction()
            }
        }
    }
    
    // activate audio ---------------------

    private var isAudioActivated = false

    private func activateAudio() {

        if !isAudioActivated {
            isAudioActivated = true

            Log("∿ \(#function)")
            do {
                try audioSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
                try audioSession.setActive(true)
            }
            catch { Log("∿ \(#function) !!! catch") }
        }
    }

    private func deactivateAudio() {

        if isAudioActivated {

            isAudioActivated = false
            Log("∿ \(#function)")
            do { try audioSession.setActive(false) }
            catch { Log("∿ \(#function) !!! catch") }
        }
    }

    // user action ------------------------------------

    /**
    user initiated gesture to either start or finish recording
     */
    func toggleRecordAction() {

        if isRecording() { Log("∿ \(#function) -> finish")
            if finishRecording() {
                Haptic.play(.success)
            }
        }
            // only allow recording if "show memo" is set
        else if Show.shared.canShow(.memo) { Log("∿ \(#function) -> start")
            Haptic.play(.start)
            startRecording()
        }
    }

    /**
     Setup multithread queue to prepare, animate, start locacation,
     which all must finish before beginRecording()
     */
    func startRecording() {
        
        func prepareRecording(_ done: @escaping () -> ()) {

            activateAudio() // this should already been started, so somewhat reundundant
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd__HH.mm.ss"
            let date = Date()
            let timeStr = dateFormatter.string(from: date)
            recName = "Memo_" + timeStr + ".m4a"
            groupURL = FileManager.museGroupURL().appendingPathComponent(recName)
            try? audioRecorder = AVAudioRecorder(url: groupURL!, settings: recordSettings)
            audioRecorder?.prepareToRecord()
            done()
        }

        /**
         Start recoding session if still active. Sometimes the watch will deactivate after starting the preparations.
         */
        func beginRecording() {

            if Active.shared.isOn { Log("∿ \(#function) Active.isOn")
                // when recBgnTime < recEndTime, isRecording() returns true
                recBgnTime = Date().timeIntervalSince1970
                audioRecorder?.record()
                audioTimer = Timer.scheduledTimer(timeInterval: recDur, target: self, selector: #selector(timedOutRecording), userInfo: nil, repeats: false)
                Anim.shared.gotoRecordSpoke(on:true)
            }
                // became unactive while setting up
            else { Log("∿ \(#function) aborting")
                abortTime = Date().timeIntervalSince1970
            }
        }

        // begin ---------------------------------

        if isRecording() { return }

        Location.shared.requestLocation() {}

        DispatchQueue.global(qos: .utility).async {

            let group = DispatchGroup()

            // prepare recording
            group.enter()
            prepareRecording() { // Log("∿ prepareRecording done")
                group.leave()
            }

            let _ = group.wait(timeout: .now() + 2.0)

            DispatchQueue.main.async {
                beginRecording()
            }
        }
    }

    /**
     Stop the audio recorder and animation.
     - via finishRecording
     - via deleteRecording
     */
    private func stopRecording() { Log("∿ \(#function)")

        recEndTime = Date().timeIntervalSince1970

        audioTimer.invalidate()
        audioRecorder?.stop()
        Anim.shared.gotoRecordSpoke(on: false)
    }



    /**
     Finish and save recording
     - via: user triple-tapped or nodded device
     - via: audioTimer fired after recDur seconds
     */
    func finishRecording() -> Bool {  Log("∿ \(#function)")

        if !isRecording() { return false }

        stopRecording()

        let deltaTime = recEndTime - recBgnTime
        if deltaTime < minimumDuration {
            Log("∿ \(#function) abort \(deltaTime)")
            audioRecorder?.deleteRecording()
            return false
        }
        else {
            Log("∿ \(#function) save \(deltaTime)")
            saveRecording()
            return true
        }
    }
    @objc func timedOutRecording() {  Log("∿ \(#function)")
        let _ = finishRecording()
    }


    /**
     when watch screen becomes inactive, abort a freshly started recording.
     and if so, stop it
     -via: Active::stopActive
     */
    func maybeStopRecording() {

        if !isRecording() { // Log("∿ \(#function) -> NOT recording")
            return
        }

        if finishRecording() { // Log("∿ \(#function) -> success")
             Haptic.play(.success)
        }
        else { // Log("∿ \(#function) -> abort")
            abortTime = Date().timeIntervalSince1970
        }
        deactivateAudio()
    }

    /**
     when watch screen becomes inactive for a short time after aborting a recording, restart recording.
     -via: Active::stopActive
     */
    func maybeRestartRecording() {

        let timeNow = Date().timeIntervalSince1970
        let deltaTime = (timeNow - abortTime)
        if  deltaTime < waitingPeriod {
            Log("∿ \(#function) restarting \(deltaTime)")
            startRecording() // will call activateAudio()
        }
        else {
            Log("∿ \(#function) NOT \(deltaTime)")
            DispatchQueue.main.async {
                self.activateAudio()
            }
        }
    }

    /**
     Move temp file to documents. For watch: transfer to iPhone
     - via: finishRecording
     */
    func saveRecording() {

        let duration = recEndTime - recBgnTime
        if duration < minimumDuration { // ignore zero duration recordings
            return Log("∿ duration <  \(minimumDuration)")
        }
        if let groupURL = groupURL {

            // Move  file to documents directory so that WatchConnectivity can transfer it.
            let docURL = FileManager.documentUrlFile(recName)
            let metaData = ["fileName" : recName as AnyObject,
                            "fileDate" : recBgnTime as AnyObject]

            if  let _ = try? FileManager().moveItem(at:groupURL, to:docURL) {
                #if os(watchOS)
                    Log("→ \(#function) transfer recName:\(recName)")
                    if !Session.shared.transferFile(docURL, metadata:metaData) {
                        Log("∿ \(#function) Failed !!! could not transfer file \n   to:\(docURL)")
                    }
                #endif
                Log("∿ \(#function): \(recName)")
            }
            else {
                Log("∿ \(#function) Failed !!! \n   from:\(groupURL) \n   to:\(docURL)")
            }
            createMemoEvent()
        }
    }
    /**
     After saving a recording file, create a Memo event for timeline, and attempt to transcribe audio speech to text.
     - via: saveRecording
     */
    func createMemoEvent() { Log("∿ \(#function)")

        let coord = Location.shared.getLocation()
        let event = MuEvent(.memoRecord, "Memo", recBgnTime, recName, coord, .white)

        Actions.shared.doAddEvent(event, isSender:true)
        Memos.doTranscribe(event, recName, isSender:true)

        #if os(watchOS)
            Crown.shared.updateCrown()
        #endif
    }

    /**
     User shaked device to delete recording
     -via: Motion.shake2
     */
    @objc func deleteRecording() {

        if  isRecording() { Log("∿ \(#function)")

            stopRecording()
            audioRecorder?.deleteRecording()
            Haptic.play(.failure)
        }
    }

}


