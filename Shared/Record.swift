
import WatchKit
import UIKit
import AVFoundation

class Record: NSObject, CLLocationManagerDelegate {

    static let shared = Record()

    let audioSession = AVAudioSession.sharedInstance()
    var audioRecorder: AVAudioRecorder?

    let recDur = TimeInterval(30) // recording duration
    var recTime = TimeInterval(0)
    var recName = ""
    var groupURL: URL?

    var isRecording  = false
    var audioTimer   = Timer() // audio note timer

    let recordSettings = [
        AVSampleRateKey : NSNumber(value: Float(16000.0)),
        AVFormatIDKey : NSNumber(value:Int32(kAudioFormatMPEG4AAC)),
        AVNumberOfChannelsKey : NSNumber(value: Int32(1)),
        AVEncoderAudioQualityKey : NSNumber(value: Int32(AVAudioQuality.medium.rawValue))]


//    let audioSession = AVAudioSession.sharedInstance()
//    if let desc = audioSession.availableInputs?.first(where: { (desc) -> Bool in
//        return desc.portType == AVAudioSessionPortUSBAudio
//    }){
//        do{
//            try audioSession.setPreferredInput(desc)
//        } catch let error{
//            print(error)
//        }
//    }


    // Audio -----------------------------------

    func recordAudioAction() {
        
        Log("∿ \(#function)")
        
        if isRecording {
            finishRecording()
            Haptic.play(.stop)
        }
            // only allow recording if "show memo" is set
        else if Show.shared.canShow(.memo) {
            Haptic.play(.start)
            queueRecording()
        }
    }

    func activateAudio() { Log("∿∿∿ \(#function)")

        do {
            try audioSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
            try audioSession.setActive(true)
         }
        catch { Log("∿∿∿ \(#function) !!! catch") }
    }
    func deactivateAudio() { Log("∿∿∿ \(#function)")
        do { try audioSession.setActive(false) }
        catch { Log("∿∿∿ \(#function) !!! catch") }
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
            recTime = Date().timeIntervalSince1970
            groupURL = FileManager.museGroupURL().appendingPathComponent(recName)
            try? audioRecorder = AVAudioRecorder(url: groupURL!, settings: recordSettings)
            audioRecorder?.prepareToRecord()
            done()
        }
        func animateRecording(_ done: @escaping () -> ()) {

            Anim.shared.gotoRecordSpoke(on:true)
            Anim.shared.setRecordingClosure {
                done()
            }
        }
        func startRecording() {
            audioRecorder?.record()
            audioTimer = Timer.scheduledTimer(timeInterval: recDur, target: self, selector: #selector(finishRecording), userInfo: nil, repeats: false)
        }

        if isRecording {  return }
        isRecording = true
        activateAudio()
        let queue = DispatchQueue(label: "com.muse.recordAudio", attributes: .concurrent, target: .main)
        let group = DispatchGroup()

        Log("∿∿∿ \(#function)")

         // prepare recording
        group.enter()
        queue.async (group: group) {
            prepareRecording() {
                 Log("∿ prepareRecording() done")
                group.leave()
            }
        }
        // animate recording
        group.enter()
        queue.async (group: group) {
            animateRecording {
                 Log("∿ \(#function)")
                group.leave()
            }
        }
        // location
        group.enter()
        queue.async (group: group) {
             Location.shared.requestLocation() {
                Log("∿ Location done")
                group.leave()
            }
        }
        // events + reminders done
        group.notify(queue: queue, execute: {
            Log("∿∿∿ startRecording() done")
            startRecording()
        })
    }


    func stopRecording() -> Bool { Log("∿∿∿ \(#function)")

        let wasRecording = isRecording
        if isRecording {
            isRecording = false
            audioTimer.invalidate()
            audioRecorder?.stop()
            deactivateAudio()
        }
        return wasRecording
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
                                "fileDate" : recTime as AnyObject]

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

        let coord = Location.shared.getLocation()
        let event = MuEvent(.memo, "Memo", recTime, recName, coord, .white)

        Actions.shared.doAddEvent(event, isSender:true)
        Memos.doTranscribe(event, recName, isSender:true)
        Haptic.play(.success)

        #if os(watchOS)
            Crown.shared.updateCrown()
        #endif
    }

    
  }


