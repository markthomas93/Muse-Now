//
//  Transcribe+AppleBuf.swift
// muse •
//
//  Created by warren on 5/3/18.
//  Copyright © 2018 Muse. All rights reserved.
//

import Foundation
#if os(iOS)
import Speech

extension Transcribe {

    func appleBufferData(_ data:NSData) {
        let buffer = Data2Pcm(data)
        if bufferRequest == nil {
            appleBufferStart()
        }
        bufferRequest?.append(buffer)
    }

    func appleBufferFinish() {
        bufferRequest?.endAudio()
        bufferRequest = nil
        recognitionTask = nil
    }

    func appleBufferCancel() {
        recognitionTask?.cancel()
        recognitionTask = nil
    }

    func appleBufferResult(_ txt: String) {
    }


    func appleBufferStart() {

        if !recognizer.isAvailable {
            Log("✏ \(#function) recognizer is NOT available")
            return
        }

        // Cancel the previous task if it's running.
        if let recognitionTask = recognitionTask {
            recognitionTask.cancel()
            self.recognitionTask = nil
        }
        bufferRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let bufferRequest = bufferRequest else {
            Log("✏ Unable to created a SFSpeechAudioBufferRecognitionRequest object")
            return
        }
        bufferRequest.shouldReportPartialResults = true
        recognitionTask = recognizer.recognitionTask(with: bufferRequest) { result, error in

            if let result = result {
                // matches a muse template
                let museFound = self.matchMuseFound(result)
                if museFound.str != nil {
                    Session.shared.sendMsg( ["Transcribe" : museFound.str], isCacheable: true)
                    Log("✏ muse: \(museFound.str!)")
                }
                    // does not match a muse template, so send unmatched result
                else {
                    Session.shared.sendMsg( ["Transcribe" : result.bestTranscription], isCacheable: true)
                    Log("✏ stt: \(result.bestTranscription)")
                }
            }
            else if let error = error {
                Log("✏ \(#function) \(error.localizedDescription)")
            }
        }
    }

}
#endif
