//  Transcribe+Apple.swift
//  Created by warren on 9/6/17.
//  Copyright © 2017 Muse. All rights reserved.

import Foundation
import Speech
extension Transcribe {
    
    func authorize() {

        SFSpeechRecognizer.requestAuthorization { authStatus in

            // cannot call on main thread?
            OperationQueue.main.addOperation {
                switch authStatus {
                case .authorized:    break
                case .denied:        break
                case .restricted:    break
                case .notDetermined: break
                }
            }
        }
    }

    func appleBufferStart() {

        if !recognizer.isAvailable {
            print("~ \(#function) recognizer is NOT available")
            return
        }

        // Cancel the previous task if it's running.
        if let recognitionTask = recognitionTask {
            recognitionTask.cancel()
            self.recognitionTask = nil
        }
        request = SFSpeechAudioBufferRecognitionRequest()
        guard let request = request else {
            print("~ Unable to created a SFSpeechAudioBufferRecognitionRequest object")
            return
        }
        request.shouldReportPartialResults = true
        recognitionTask = recognizer.recognitionTask(with: request) { result, error in

            if let result = result {
                // matches a muse template
                let museFound = self.matchMuseFound(result)
                if museFound.str != nil {
                    Session.shared.sendMsg( ["class"  : "Transcribe",
                                             "result" : museFound.str])
                     print("✏ muse: \(museFound.str)")
                }
                    // does not match a muse template, so send unmatched result
                else {
                    Session.shared.sendMsg( ["class"  : "Transcribe",
                                             "result" : result.bestTranscription])
                    print("✏ stt: \(result.bestTranscription)")
                }
            }
            else if let error = error {
                print("✏ \(#function) \(error.localizedDescription)")
            }
        }
    }


    func matchMuseFound(_ result: SFSpeechRecognitionResult) -> MuseFound {

        var log = "✏\n"

        var nearestFound = MuseFound(result.bestTranscription.formattedString,nil,Int.max)

        for trans in result.transcriptions {

            let txt = trans.formattedString.lowercased()
            log += "   \"\(txt)\" "
            let found = Muse.shared.findMatch(txt)
            log += Muse.shared.resultStr(found) + "\n"

            if  nearestFound.hops > found.hops, found.hops > -1 {
                nearestFound = MuseFound(found)
            }

            for seg in trans.segments {
                log += String(format:"     t:%.2f d:%.2f conf:%.3f \"%@\"\n",
                              seg.timestamp, seg.duration, seg.confidence, seg.substring)
            }
        }
        log += "     ✏ \(nearestFound.str!)"
        printLog(log)
        return nearestFound
    }

    func appleSttUrl(_ url: URL, _ completion: @escaping (_ found: MuseFound) -> Void) {

        var museFound = MuseFound("Memo",nil,Int.max)

        if !recognizer.isAvailable {
            
            print("✏ \(#function) recognizer is NOT available")
            completion(museFound)
            return
        }
        else {

            let request = SFSpeechURLRecognitionRequest(url: url)
            request.shouldReportPartialResults = false
            request.contextualStrings = Muse.shared.contexualStrings
            request.taskHint = .search

            recognizer.recognitionTask(with: request) { result, error in

                if let result = result {
                    museFound = self.matchMuseFound(result)
                }
                else if let error = error {
                    print(error)
                }
                completion(museFound)
            }
        }
    }

    func appleSttFile(_ recName: String, _ event:MuEvent! = nil)  {

        let docURL = FileManager.documentUrlFile(recName)
        //print ("✏ \(#function) url:\(docURL)")
        appleSttUrl(docURL) { matchFound in
            if let _ = matchFound.str {
                if let event = event {
                    event.title = matchFound.str
                    event.sttApple = matchFound.str
                }
                Muse.shared.execFound(matchFound, event)
                Actions.shared.doUpdateEvent(event, isSender:true)
            }
        }
    }

}
