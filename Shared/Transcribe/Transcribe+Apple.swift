 //
//  Transcribe+Apple.swift
//  Klio
//
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
                // matches a klio template
                let klioFound = self.matchKlioFound(result)
                if klioFound.str != nil {
                    Session.shared.sendMsg( ["class"  : "transcribe",
                                             "result" : klioFound.str])
                     print("✏ klio: \(klioFound.str)")
                }
                    // does not match a klio template, so send unmatched result
                else {
                    Session.shared.sendMsg( ["class"  : "transcribe",
                                             "result" : result.bestTranscription])
                    print("✏ stt: \(result.bestTranscription)")
                }
            }
            else if let error = error {
                print("✏ \(#function) \(error.localizedDescription)")
            }
        }
    }


    func matchKlioFound(_ result: SFSpeechRecognitionResult) -> KlioFound {

        var log = "✏\n"

        var nearestFound = KlioFound(result.bestTranscription.formattedString,nil,Int.max)

        for trans in result.transcriptions {

            let txt = trans.formattedString.lowercased()
            log += "   \"\(txt)\" "
            let found = Klio.shared.findMatch(txt)
            log += Klio.shared.resultStr(found) + "\n"

            if  nearestFound.hops > found.hops, found.hops > -1 {
                nearestFound = KlioFound(found)
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

    func appleSttUrl(_ url: URL, _ completion: @escaping (_ found: KlioFound) -> Void) {

        var klioFound = KlioFound("Memo",nil,Int.max)

        if !recognizer.isAvailable {
            print("✏ \(#function) recognizer is NOT available")
            completion(klioFound)
            return
        }
        else {

            let request = SFSpeechURLRecognitionRequest(url: url)
            request.shouldReportPartialResults = false
            request.contextualStrings = Klio.shared.contexualStrings
            request.taskHint = .search

            recognizer.recognitionTask(with: request) { result, error in

                if let result = result {
                    klioFound = self.matchKlioFound(result)
                }
                else if let error = error {
                    print(error)
                }
                completion(klioFound)
            }
        }
    }

    func appleSttFile(_ recName: String, _ event:KoEvent! = nil)  {

        let docURL = FileManager.documentUrlFile(recName)
        //print ("✏ \(#function) url:\(docURL)")
        appleSttUrl(docURL) { matchFound in
            if let _ = matchFound.str {
                if let event = event {
                    event.title = matchFound.str
                    event.sttApple = matchFound.str
                }
                Klio.shared.execFound(matchFound, event)
                Actions.shared.doUpdateEvent(event, isSender:true)
            }
        }
    }

}
