
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
        
        printLog("∿ \(#function)")
        
        if isRecording {
            finishRecording()
            Haptic.play(.stop)
        }
        else {
            Haptic.play(.start)
            queueRecording()
        }
    }

    func activateAudio() { printLog("∿∿∿ \(#function)")

        do {
            try audioSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
            try audioSession.setActive(true)
         }
        catch { printLog("∿∿∿ \(#function) !!! catch") }
    }
    func deactivateAudio() { printLog("∿∿∿ \(#function)")
        do { try audioSession.setActive(false) }
        catch { printLog("∿∿∿ \(#function) !!! catch") }
    }

     /// setup multithread queue to prepare, animate, start locacation,
    /// which all must finish before startRecording()
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

        printLog("∿∿∿ \(#function)")

         // prepare recording
        group.enter()
        queue.async (group: group) {
            prepareRecording() {
                 printLog("∿ prepareRecording() done")
                group.leave()
            }
        }
        // animate recording
        group.enter()
        queue.async (group: group) {
            animateRecording {
                 printLog("∿ \(#function)")
                group.leave()
            }
        }
        // location
        group.enter()
        queue.async (group: group) {
             Location.shared.requestLocation() {
                printLog("∿ Location done")
                group.leave()
            }
        }
        // events + reminders done
        group.notify(queue: queue, execute: {
            printLog("∿∿∿ startRecording() done")
            startRecording()
        })
    }


    func stopRecording() -> Bool { printLog("∿∿∿ \(#function)")

        let wasRecording = isRecording
        if isRecording {
            isRecording = false
            audioTimer.invalidate()
            audioRecorder?.stop()
            deactivateAudio()
        }
        return wasRecording
    }

    @objc func cancelRecording() { printLog("∿∿∿ \(#function)")
        if stopRecording() {
            audioRecorder?.deleteRecording()
        }
    }

    /**
     Finish and save recording, via:
     - user tapped or twisted device
     - audioTimer fired after recDur seconds
     */
    @objc func finishRecording() {  printLog("∿∿∿ \(#function)")

        if !stopRecording() { return }
        Anim.shared.gotoRecordSpoke(on: false)

        if let groupURL = groupURL {

            if FileManager.getFileSize(groupURL) < 26000 { // ignore zero duration recordings
                printLog("∿ filesize < 26000 for groupURL:\(recName)")
            }
            else {
                // Move  file to documents directory so that WatchConnectivity can transfer it.
                let docURL = FileManager.documentUrlFile(recName)
                let metaData = ["fileName" : recName as AnyObject,
                                "fileDate" : recTime as AnyObject]

                if  let _ = try? FileManager().moveItem(at:groupURL, to:docURL) {
                    #if os(watchOS)
                        if !Session.shared.transferFile(docURL, metadata:metaData) {
                            printLog("∿ \(#function) Failed !!! could not transfer file \n   to:\(docURL)")
                        }
                    #endif
                    printLog("∿ \(#function): \(recName)")
                }
                else {
                    printLog("∿ \(#function) Failed !!! \n   from:\(groupURL) \n   to:\(docURL)")
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


