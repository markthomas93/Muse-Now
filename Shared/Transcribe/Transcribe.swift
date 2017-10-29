// Memos+STT.swift
// transcribe Audio to text usingl Apple STT API

import Foundation

#if os(iOS)
import Speech
class Transcribe {

    static var shared = Transcribe()

    let recognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))!
    var request: SFSpeechAudioBufferRecognitionRequest?
    var recognitionTask: SFSpeechRecognitionTask?
    var authorized = SFSpeechRecognizerAuthorizationStatus.notDetermined

    func appleBufferData(_ data:NSData) {
        let buffer = Data2Pcm(data)
        if request == nil {
            appleBufferStart()
        }
        request?.append(buffer)
    }

    func appleBufferFinish() {
        request?.endAudio()
        request = nil
        recognitionTask = nil
    }
    func appleBufferCancel() {
        recognitionTask?.cancel()
        recognitionTask = nil
    }
    func appleBufferResult(_ txt: String) {
    }
}
#else
class Transcribe {

    static var shared = Transcribe()
    func appleBufferResult(_ txt: String) {
        printLog("✏ \(#function)(\(txt)")
        Actions.shared.doSetTitle(txt)
    }
}
#endif

