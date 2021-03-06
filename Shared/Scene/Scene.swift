
import SceneKit
import SpriteKit
import UIKit
import WatchKit
import AVFoundation

public protocol MuseTableDelegate : NSObjectProtocol {
    
    func scrollSceneEvent(_ event: MuEvent) // scroll table and select event
    func scrollDialEvent(_ event: MuEvent,_ delta:Int) // scroll table and center event, but dont select
    func updateTable(_ events: [MuEvent])
    func updateTimeEvent()
    func updateCellMarks()
    func toggleCurrentCell() -> (MuEvent?, Bool)
}

class Scene: SKScene  {

    static var nextId = 0
    static func getNextId() -> Int { nextId += 1 ; return nextId }

    let id = Scene.getNextId()
    let actions  = Actions.shared
    let dayHour  = DayHour.shared
    let muEvents = MuEvents.shared
    let session  = Session.shared
    let audioPlayer = AVAudioPlayer()

    let say      = Say.shared
    let anim     = Anim.shared
    let dots     = Dots.shared

    var dial: SKSpriteNode!
    var dialShader: SKShader!
    var center = CGPoint(x:0, y:0)
    var radius = CGFloat(0)
    var fade   = Float(0)
 
    var debugUpdate = false
    var textures      : [SKTexture] = [] // main dial with mask

    var complications : [SKTexture] = []  // complication full image, background, foreground

    var uDialFrame     : SKUniform!
    var uDialFade      : SKUniform! 
    var uDialCount     : SKUniform! 
    var uDialAnim      : SKUniform! 
    var uDialMask      : SKUniform! 
    var uDialPal       : SKUniform! 
    
    var futrAniTex : SKTexture! 
    var pastAniTex : SKTexture! 
    var futrPalTex : SKTexture! 
    var pastPalTex : SKTexture!
    var recPalTex  : SKTexture! // recording texture
    
    var indexWidth = 170 // 24 hours * 7 days + rim + hub

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    override init(size:CGSize) {

        super.init(size:size)
        backgroundColor = .black
        scaleMode = .aspectFill
        initSprites()
    }
    override func sceneDidLoad() {
        
        Log("⎚ \(#function)")
        anim.scene = self
        center = CGPoint(x: size.width/2, y: size.height/2)
        radius =  min(size.width, size.height)/2
        dayHour.updateTime()
    }

    /** update dots and time for current texture */
    func updateSceneFinish() { Log("⎚ \(#function)")
        
        dayHour.updateTime() // set reference for current hour and day
        dots.updateDotEvents(muEvents.events)  //??? attempted
        dots.makeSelectFade()
        updateTextures()
        dial.zRotation = CGFloat(Double(36-dayHour.hour0) / 24.0 * (2*Double.pi))
    }

    /**
     Update palette and textures on shader
     - via: Scene.updateSceneFinish
     - via: Actions.markAction
     */
    func updateTextures () { //Log("⎚ \(#function)")
        
        updatePalTex()
        updateAniTex()
        updateUniforms()
        updatePastFutr()
    }

    // SKScene callback game loop -------------------

    #if os(watchOS)
    var countdown = 2 // kludge to overcome white flash on apple watch
    #endif

    override func update(_ currentTime: TimeInterval) {

        if anim.updateScene(currentTime) {

            uDialFrame?.floatValue = (abs(anim.sceneFrame)+0.5)/Float(Anidex.animEnd.rawValue)
            updatePastFutr()
        }
        #if os(watchOS)
            if countdown > 0 {
                countdown -= 1
                if countdown == 0 {
                    WatchCon.shared.skInterface.setAlpha(1)
                }
            }
        #endif
        if debugUpdate {
            let time = String(format:"%.2f",currentTime)
            actions.doSetTitle("\(anim.animNow):\(time)")
        }
    }
}






















































