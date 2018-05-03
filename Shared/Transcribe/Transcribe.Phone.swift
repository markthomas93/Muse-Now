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
                // Actions.shared.doUpdateEvent(event, isSender:true)
                done()
            }
        }
    }
}

