 
 import AVFoundation
 import Foundation

 class Audio : NSObject, AVAudioPlayerDelegate {
    
    static let shared = Audio()

    var actions = Actions.shared
    var dayHour = DayHour.shared

    var audioPlayer: AVAudioPlayer!
    var audioSession = AVAudioSession.sharedInstance()
    var sayVolume = Float(0.5)
    var finished: CallBool? 

    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        audioPlayer.stop()
        audioPlayer.prepareToPlay()
        finished?(true)
        finished = nil
    }


    func startPlaybackSession() { Log("🔈 \(#function)")
        audioPlayer?.stop()
        do {
            // AVAudioSessionCategoryPlayAndRecord will play back only small ear speaker
            // try audioSession.setCategory(AVAudioSessionCategoryPlayAndRecord, with: [.allowBluetoothA2DP,.interruptSpokenAudioAndMixWithOthers] )
            // try audioSession.setCategory(AVAudioSessionCategoryPlayback, with: [.allowBluetoothA2DP,.interruptSpokenAudioAndMixWithOthers] )
            try audioSession.setActive(false)
            try audioSession.setCategory(AVAudioSessionCategorySoloAmbient, with: [.allowBluetoothA2DP,.interruptSpokenAudioAndMixWithOthers] )
        }
        catch { /*Log("🔈 !!! \(#function) Error:\(error)")*/ }

    }
    func finishPlaybackSession() {

        if  audioPlayer?.isPlaying == true { Log("🔈 \(#function)")
            audioPlayer.stop()

            do { try self.audioSession.setActive(false, with: .notifyOthersOnDeactivation) }
            catch { print("🔈\(#function) Error:\(error)")}
        }
        actions.doSetTitle("")
    }


    func playUrl(url:URL,_ completion: @escaping CallBool) {

        startPlaybackSession()

        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer.setVolume(1.0, fadeDuration: 0.1)
            audioPlayer.delegate = self
            audioPlayer.play()
            finished = completion
        }
        catch {
            Log("🔈 \(#function) error")
            completion(false)
        }
    }

 }
