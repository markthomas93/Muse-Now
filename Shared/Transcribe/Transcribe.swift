// Memos+STT.swift
// transcribe Audio to text using Apple STT API

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
        func transcribe(_ item:SayItem) {

            if item.title == "Memo" {
                let url = FileManager.documentUrlFile(item.spoken)
                Transcribe.shared.appleSttUrl(url) { found in
                    if let str = found.str,
                        str != "",
                        let event = item.event {
                        event.sttApple = found.str
                        event.title = found.str
                        Actions.shared.doUpdateEvent(event, isSender: true)
                    }
                }
            }
        }
    }

#else

    class Transcribe {

        static var shared = Transcribe()
        func appleBufferResult(_ txt: String) {
            Log("✏ \(#function)(\(txt)")
            Actions.shared.doSetTitle(txt)
        }
        func transcribe(_ item:SayItem) {
        }

    }

#endif

