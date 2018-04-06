
import WatchKit
import UIKit
import AVFoundation

class Record: NSObject, CLLocationManagerDelegate {

    static let shared = Record()

    let audioSession = AVAudioSession.sharedInstance()
    var audioRecorder: AVAudioRecorder?

    let recDur = TimeInterval(30) // recording duration
    var recBgnTime = TimeInterval(0)
    var recEndTime = TimeInterval(0)
    var recName = ""
    var groupURL: URL?
    var audioTimer   = Timer() // audio note timer

    let recordSettings = [
        AVSampleRateKey : NSNumber(value: Float(16000.0)),
        AVFormatIDKey : NSNumber(value:Int32(kAudioFormatMPEG4AAC)),
        AVNumberOfChannelsKey : NSNumber(value: Int32(1)),
        AVEncoderAudioQualityKey : NSNumber(value: Int32(AVAudioQuality.medium.rawValue))]

    func isRecording() -> Bool {
        return recEndTime < recBgnTime
    }


    // Audio -----------------------------------

    func recordAudioAction() {
        
        Log("∿ \(#function)")
        
        if isRecording() {
            finishRecording()
            Haptic.play(.stop)
        }
            // only allow recording if "show memo" is set
        else if Show.shared.canShow(.memo) {
            Haptic.play(.start)
            queueRecording()
        }
    }

    var isAudioActivated = false
    func activateAudio() { Log("∿∿∿ \(#function)")
        if !isAudioActivated {
            do {
                try audioSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
                try audioSession.setActive(true)
                isAudioActivated = true
            }
            catch { Log("∿∿∿ \(#function) !!! catch") }
        }
    }

    func deactivateAudio() { Log("∿∿∿ \(#function)")
        do { try audioSession.setActive(false) }
        catch { Log("∿∿∿ \(#function) !!! catch") }
        isAudioActivated = false
    }

    /**
     Setup multithread queue to prepare, animate, start locacation,
     which all must finish before startRecording()
     */
    func queueRecording() {
        
        func prepareRecording(_ done: @escaping () -> ()) {

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

        func beginRecording() {
            audioRecorder?.record()
            recBgnTime = Date().timeIntervalSince1970
            audioTimer = Timer.scheduledTimer(timeInterval: recDur, target: self, selector: #selector(finishRecording), userInfo: nil, repeats: false)
            Location.shared.requestLocation() {}
        }

        // begin

        if !isRecording() {
            activateAudio()
            Anim.shared.gotoRecordSpoke(on:true)
            prepareRecording() {
                beginRecording()
            }
        }
    }

    func stopRecording() -> Bool {
        
        if isRecording() {
            Log("∿∿∿ \(#function)")
            recEndTime = Date().timeIntervalSince1970
            audioTimer.invalidate()
            audioRecorder?.stop()
            deactivateAudio()
            return true
        }
        return false
    }

    @objc func cancelRecording() { Log("∿∿∿ \(#function)")

        if stopRecording() {
            audioRecorder?.deleteRecording()
        }
    }

    /**
     Finish and save recording, via:
     - user tapped or twisted device
     - audioTimer fired after recDur seconds
     */
    @objc func finishRecording() {  Log("∿∿∿ \(#function)")

        if !stopRecording() { return }
        Anim.shared.gotoRecordSpoke(on: false)

        if let groupURL = groupURL {

            if FileManager.getFileSize(groupURL) < 26000 { // ignore zero duration recordings
                Log("∿ filesize < 26000 for groupURL:\(recName)")
            }
            else {
                // Move  file to documents directory so that WatchConnectivity can transfer it.
                let docURL = FileManager.documentUrlFile(recName)
                let metaData = ["fileName" : recName as AnyObject,
                                "fileDate" : recBgnTime as AnyObject]

                if  let _ = try? FileManager().moveItem(at:groupURL, to:docURL) {
                    #if os(watchOS)
                        if !Session.shared.transferFile(docURL, metadata:metaData) {
                            Log("∿ \(#function) Failed !!! could not transfer file \n   to:\(docURL)")
                        }
                    #endif
                    Log("∿ \(#function): \(recName)")
                }
                else {
                    Log("∿ \(#function) Failed !!! \n   from:\(groupURL) \n   to:\(docURL)")
                }
                recordAudioFinish()
            }
        }
    }

    func recordAudioFinish() {

        Log("∿ \(#function)")

        let coord = Location.shared.getLocation()
        let event = MuEvent(.memo, "Memo", recBgnTime, recName, coord, .white)

        Actions.shared.doAddEvent(event, isSender:true)
        Memos.doTranscribe(event, recName, isSender:true)
        Haptic.play(.success)

        #if os(watchOS)
            Crown.shared.updateCrown()
        #endif
    }

    func recordAudioDelete() {
        Log("∿ \(#function)")
        if isRecording() {
            finishRecording()
            Haptic.play(.failure)
        }
    }

}


