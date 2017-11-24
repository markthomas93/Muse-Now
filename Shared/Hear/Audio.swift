 
 import AVFoundation
 import Foundation

 class Audio : NSObject, AVAudioPlayerDelegate {
    
    static let shared = Audio()

    var actions = Actions.shared
    var dayHour = DayHour.shared

    var audioPlayer: AVAudioPlayer!
    var audioSession = AVAudioSession.sharedInstance()
    var sayVolume = Float(0.5)

    func startPlaybackSession() { printLog("🔈 \(#function)")
        do {
            // AVAudioSessionCategoryPlayAndRecord will play back only small ear speaker
            // try audioSession.setCategory(AVAudioSessionCategoryPlayAndRecord, with: [.allowBluetoothA2DP,.interruptSpokenAudioAndMixWithOthers] )
            // try audioSession.setCategory(AVAudioSessionCategoryPlayback, with: [.allowBluetoothA2DP,.interruptSpokenAudioAndMixWithOthers] )
            try audioSession.setCategory(AVAudioSessionCategorySoloAmbient, with: [.allowBluetoothA2DP,.interruptSpokenAudioAndMixWithOthers] )
            //?? sayTimer?.invalidate() //?? new
        }
        catch {  print("\(#function) Error:\(error)") }

    }
    func finishPlaybackSession() { printLog("🔈 \(#function)")

        if let audioPlayer = audioPlayer,
            audioPlayer.isPlaying {
            audioPlayer.stop()

            do { try self.audioSession.setActive(false, with: .notifyOthersOnDeactivation) }
            catch { print("🔈\(#function) Error:\(error)")}
        }

        actions.doSetTitle("")
    }


    func playUrl(url:URL) -> Bool {

        startPlaybackSession()

        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer.setVolume(1.0, fadeDuration: 0.1)
            audioPlayer.delegate = self
            audioPlayer.play()
        }
        catch {
            printLog("🔈 \(#function) error")
            return false
        }
        return true
    }

 }
