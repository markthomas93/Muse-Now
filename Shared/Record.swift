
import WatchKit
import UIKit
import AVFoundation
import CoreAudio

class Record: NSObject, CLLocationManagerDelegate {

    static let shared = Record()

    let audioSession = AVAudioSession.sharedInstance()
    var audioRecorder: AVAudioRecorder?

    let recDuration = TimeInterval(30) // recording duration
    var recBgnTime = TimeInterval(0)
    var recEndTime = TimeInterval(0)
    var abortTime = TimeInterval(0)
    var fileName = ""
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

    let waitingPeriod   = TimeInterval(2.0)
    let minimumDuration = TimeInterval(1.0)

    func recordAfterWaitingPeriod() {

        if isRecording() {
            Log("∿ \(#function) isRecording -> off")
            toggleRecordAction()
        }
        else {

            let deltaEnd = Date().timeIntervalSince1970 - recEndTime

            Log(String(format:"∿ \(#function) delta:%.2f dur:%.2f", deltaEnd, recEndTime - recBgnTime))

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
     User initiated gesture to either start or finish recording
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
            startRecording() {}
        }
    }

    /**
     Setup multithread queue to prepare, animate, start location, which all must finish before beginRecording()
     */
    func startRecording(_ done: @escaping CallVoid) {

        /** setup recording route and file destination */
        func prepareRecording(_ done: @escaping CallVoid) {

            activateAudio() // this should already been started, so somewhat reundundant
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd__HH.mm.ss"
            let date = Date()
            let timeStr = dateFormatter.string(from: date)
            fileName = "Memo_" + timeStr + ".m4a"

            do {
                groupURL = FileManager.museGroupURL().appendingPathComponent(fileName)
                try audioRecorder = AVAudioRecorder(url: groupURL!, settings: recordSettings)
                audioRecorder?.prepareToRecord()
            }
            catch {
                Log("∿ \(#function) problem with url:\(groupURL!)")
            }
            done()
        }

        /** Start recoding session if still active. Sometimes the watch will deactivate after starting the preparations. */
        func beginRecording(_ done: @escaping CallVoid) {

            if Active.shared.isOn { Log("∿ \(#function) Active.isOn")

                self.recBgnTime = Date().timeIntervalSince1970 // when recBgnTime < recEndTime, isRecording() returns true
                self.audioRecorder?.record()
                self.audioTimer = Timer.scheduledTimer(timeInterval: self.recDuration, target: self, selector: #selector(self.timedOutRecording), userInfo: nil, repeats: false)
            }
                // became unactive while setting up
            else { Log("∿ \(#function) aborting")
                abortTime = Date().timeIntervalSince1970
            }
            done()
        }

        // begin ---------------------------------

        if isRecording() { return done() }

        DispatchQueue.global(qos: .utility).async {

            let group = DispatchGroup()

            // animate record spoke
            group.enter()
            Anim.shared.gotoRecordSpoke(on: true) {
                group.leave()
            }

            // prepare location
            group.enter()
            Location.shared.requestLocation() { // Log("∿ requestLocation done")
                group.leave()
            }

            // prepare recording
            group.enter()
            prepareRecording() { // Log("∿ prepareRecording done")
                group.leave()
            }

            let _ = group.wait(timeout: .now() + 2.0)

             // prepare recording
            beginRecording() {
                done()
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
        Anim.shared.gotoRecordSpoke(on: false) {}
    }

    /** Finish and save recording
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
     When watch screen becomes inactive, abort a freshly started recording, and then deactivate.
     - via: Active::stopActive
     */
    func maybeStopRecording() {

        if isRecording() { // Log("∿ \(#function) -> NOT recording")

            if finishRecording() { // Log("∿ \(#function) -> success")
                Haptic.play(.success)
            }
            else { // Log("∿ \(#function) -> abort")
                abortTime = Date().timeIntervalSince1970
            }
        }
        deactivateAudio()
    }

    /**
     when watch screen becomes inactive for a short time after aborting a recording, restart recording.
     - via: Active::stopActive
     */
    func maybeRestartRecording(_ done: @escaping CallBool) {

        let timeNow = Date().timeIntervalSince1970
        let deltaTime = (timeNow - abortTime)
        if  deltaTime < waitingPeriod {
            Log("∿ \(#function) restarting \(deltaTime)")
            startRecording() {
                done(true)
            }
        }
        else {
            Log("∿ \(#function) NOT \(deltaTime)")
            done(false)
// does this block "hey siri" ???
//            DispatchQueue.main.async {
//                self.activateAudio()
//                done(false)
//            }
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

            // Move file to documents directory so that WatchConnectivity can transfer it.
            let docURL = FileManager.documentUrlFile(fileName)

            if  let _ = try? FileManager().moveItem(at:groupURL, to:docURL) {

                let coord = Location.shared.getLocation()
                let event = MuEvent(.memoRecord, "Memo", recBgnTime, recEndTime, fileName, coord, .white)
                Transcribe.shared.waitTranscribe(event) {}
            }
            else {
                Log("∿ \(#function) Failed transfer!!! \n   from:\(groupURL) \n   to:\(docURL)")
            }
        }
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


