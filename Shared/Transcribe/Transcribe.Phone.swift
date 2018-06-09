//  Transcribe.Phone.swift
//  MuseNow
//
//  Created by warren on 5/2/18.
//  Copyright © 2018 Muse. All rights reserved.

import Foundation
import Speech

class Transcribe {

    static var shared = Transcribe()

    var pendingEvents = [String:MuEvent]() // pending items before recognition request

    let recognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))!
    var bufferRequest: SFSpeechAudioBufferRecognitionRequest?
    var recognitionTask: SFSpeechRecognitionTask?
    //var authorized = SFSpeechRecognizerAuthorizationStatus.notDetermined

    /** Parse and act upon buffer message sent from another device */
    func parseMsg(_ msg: [String:Any]) { ///... remove

        #if os(iOS)

        Log("↔︎ \(#function) " + Session.shared.dumpDict(msg))

        if let status = msg["status"] as? String {
            let transcribe = Transcribe.shared
            switch status {
            case "start":  transcribe.appleBufferStart()
            case "finish": transcribe.appleBufferFinish()
            case "cancel": transcribe.appleBufferCancel()
            default: break
            }
        }
        else if let data = msg["data"] as? NSData {
            Transcribe.shared.appleBufferData(data)
        }
        #else
        //            if let result = msg["result"] as? String {
        //                Transcribe.shared.appleBufferResult(result)
        //            }
        #endif

    }





    /**
     When app become active, process pending memo events while app was inactive
     */
    func processPendingEvents() { Log ("✏ \(#function) count: \(pendingEvents.count)")

        if !Active.shared.isOn || pendingEvents.count < 1 {
            return
        }

        if  let lastKey = pendingEvents.keys.reversed().first,
            let lastEvent = pendingEvents[lastKey] {

            appleTranscribeEvent(lastEvent) {
                self.pendingEvents.removeValue(forKey: lastKey)
                self.processPendingEvents()
            }
        }
    }


    /**
     convert audio to text
     - parameter event: MuEvent captures result
     - parameter recName: name to concatenate to documents URL
     */
    func waitTranscribe(_ event:MuEvent,_ done: @escaping CallVoid) {
        
        FileManager.waitFile(event.eventId, timeOut: 8) { found in
            
            if found {

                //... DispatchQueue.main.async {
                if Active.shared.isOn {
                    self.appleTranscribeEvent(event, done)
                }
                else {
                    self.pendingEvents[event.eventId] = event
                    done()
                }
                //... }

                // Memos.transcribeSWM(recName,event)
            }
            else {
                Log ("✏ \(#function) timedOut for file: \(event.eventId)")
                // Actions.shared.do UpdateEvent(event, isSender:true)
                done()
            }
        }
    }
}

