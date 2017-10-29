
import SceneKit
import SpriteKit
import UIKit
import WatchKit
import AVFoundation

public protocol KoTableDelegate : NSObjectProtocol {
    
    func scrollSceneEvent(_ event: KoEvent) // scroll table and select event
    func scrollDialEvent(_ event: KoEvent,_ delta:Int) // scroll table and center event, but dont select
    func updateTable(_ events: [KoEvent])
    func updateTimeEvent()
    func updateCellMarks()
    func toggleCurrentCell() -> (KoEvent?, Bool)
}

class Scene: SKScene  {

    let actions  = Actions.shared
    let dayHour  = DayHour.shared
    let koEvents = KoEvents.shared
    let session  = Session.shared
    let audioPlayer = AVAudioPlayer()
    
    let say      = Say.shared
    let anim     = Anim.shared
    let dots     = Dots.shared

    var sprite: SKSpriteNode!
    var dialShader: SKShader!
    var center = CGPoint(x:0, y:0)
    var radius = CGFloat(0)
    var fade   = Float(0)
 
    var debugUpdate = false
    var dialMask   : [SKTexture] = [] // main dial with mask

    var complications : [SKTexture] = []  // complication full image, background, foreground

    var uFrame     : SKUniform!
    var uFade      : SKUniform! 
    var uCount     : SKUniform! 
    var uAnim      : SKUniform! 
    var uMask      : SKUniform! 
    var uPal       : SKUniform! 
    
    var futrAniTex : SKTexture! 
    var pastAniTex : SKTexture! 
    var futrPalTex : SKTexture! 
    var pastPalTex : SKTexture!
    var recPalTex  : SKTexture! // recording texture
    
    var indexWidth = 170 // 24 hours * 7 days + rim + hub
    
    override func sceneDidLoad() {
        
        printLog("⎚ \(#function)")
        anim.scene = self
        center = CGPoint(x: size.width/2, y: size.height/2)
        radius =  min(size.width, size.height)/2
        scaleMode = .aspectFill
        backgroundColor = .black
        dayHour.updateTime()
        initSprite()
    }

    /// - via: Active.checkForNewHour
    /// - via: (WatchCon EventVC).ActionDelegate.doRefresh

    func pauseScene() { printLog("⎚ \(#function)")
        //??? isPaused = true 
        say.cancelSpeech()
    }

    /// - via: Actions.doRefresh
    /// - via: Actions.doAddEvent
    /// - via: Actions.doUpdateEvent

    func updateSceneFinish() { printLog("⎚ \(#function)")
        
        dayHour.updateTime() // set reference for current hour and day
        dots.updateDotEvents(koEvents.events)  //??? attempted
        dots.makeSelectFade()
        updateTextures()
        sprite.zRotation = CGFloat(Double(36-dayHour.hour0) / 24.0 * (2*Double.pi))
        isPaused = false
    }

     /// - via: Action.refresh -> updateSceneFinish
     /// - via: Scene+Marks.markAction
    func updateTextures () { //printLog("⎚ \(#function)")
        
        updatePalTex()
        updateAniTex()
        updateUniforms()
        updatePastFutr()
    }
    

        
    // SKScene callback game loop -------------------

    override func update(_ currentTime: TimeInterval) {

        if anim.updateScene(currentTime) {

            uFrame?.floatValue = (abs(anim.sceneFrame)+0.5)/Float(Anidex.animEnd.rawValue)
            updatePastFutr()
        }

        if debugUpdate {
            let time = String(format:"%.2f",currentTime)
            actions.doSetTitle("\(anim.animNow):\(time)")
        }
    }
}






















































