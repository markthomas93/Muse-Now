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


    func appleTranscribeEvent(_ event:MuEvent, _ done: @escaping CallVoid) {

        let url = FileManager.documentUrlFile(event.eventId)
        if event.type != .memoRecord { return done() } // skip already transcribed events

        appleSttUrl(url) { found in

            if  let str = found.str, str != "" {

                event.type     = .memoTrans
                event.sttApple = found.str
                event.title    = found.str
                Log("✏ iPhone::\(#function) \(found.str)")
            }
            else {
                event.type = .memoBlank
                Log("✏ iPhone::\(#function) \(found.str)")
            }
            done()
            DispatchQueue.main.async {
                Actions.shared.doUpdateEvent(event, isSender: true)
            }
        }
    }

    func appleSttUrl(_ url: URL, _ completion: @escaping (_ found: MuseFound) -> Void) {

        var museFound = MuseFound("Memo", nil, Int.max)

        if !recognizer.isAvailable {
            
            Log("✏ \(#function) recognizer is NOT available")
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
                    museFound.hops = -2
                    Log("✏ \(#function) error:\(error.localizedDescription)")
                }
                completion(museFound)
            }
        }
    }

 }
