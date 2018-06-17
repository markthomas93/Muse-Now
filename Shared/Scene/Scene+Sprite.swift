//  Scene+Sprite.swift

import SceneKit
import SpriteKit

extension Scene {
    
    /// Build shader and textures
    /// - via: sceneDidLoad

    func makeIcon() {
        #if false
        // capture images of texture for creating a viewable icon
        // let size = CGSize(width:512,height:512)
        //var dbgMask = Texture.makeTextures(5, hour:0, size, margin:8, lineWidth:0.50, dotFactor: 0.33, maskFactor: 0.50) as! [SKTexture]
        let size =  CGSize(width:1024,height:1024) // CGSize(width:512,height:512)
        var dbgMask = Texture.makeTextures(7, hour:0, size, margin:40,lineWidth:0.25, dotFactor: 0.62, maskFactor: 0.50) as! [SKTexture]
        let img0 = dbgMask[0].cgImage()
        let img1 = dbgMask[1].cgImage()
        #endif
    }

    func initSprites() {
 
        complications = Texture.makeComplication(dayHour.days, size, lineWidth:0.125, maskFactor:0.90, margin:16)
        textures = Texture.makeTextures(dayHour.days, hour:0, size, margin:8, lineWidth:0.25, dotFactor: 0.62, maskFactor: 0.50) as! [SKTexture]

        dial = SKSpriteNode(texture: textures[0], color: .black, size:size)
        dial.position = CGPoint(x:center.x, y:center.y)
        dial.color = .black

        uDialAnim  = SKUniform(name:"u_anim",  texture:futrAniTex)
        uDialMask  = SKUniform(name:"u_mask",  texture:textures[1])
        uDialPal   = SKUniform(name:"u_pal",   texture:futrPalTex)
        uDialFrame = SKUniform(name:"u_frame", float:0.0)
        uDialFade  = SKUniform(name:"u_fade",  float:1.0)
        uDialCount = SKUniform(name:"u_count", float:Float(indexWidth))

        updatePalTex()
        updateAniTex()

        uDialAnim?.textureValue = futrAniTex
        uDialPal?.textureValue = futrPalTex

        dialShader = SKShader(fileNamed: "Dial.fsh")
        
        dialShader.addUniform(uDialMask)
        dialShader.addUniform(uDialPal)
        dialShader.addUniform(uDialAnim)
        dialShader.addUniform(uDialFrame)
        dialShader.addUniform(uDialFade)
        dialShader.addUniform(uDialCount)

        dial.shader = dialShader
        addChild(dial)

        dayHour.updateTime() // set reference for current hour and day
        dial.zRotation = CGFloat(Double(36-dayHour.hour0) / 24.0 * (2*Double.pi))
    }
       

    /**
     Flip horizonally the dot index texture, which is used for both past and futr.
     Replace the color palette to reflect past or futr hours
     - via: animOut
     */
    func updateSprite(xScale:CGFloat) {
        
        if dial.xScale != xScale {
            dial.xScale = xScale
            updateUniforms()
        }
    }

    func updateUniforms() {
        if dial.xScale > 0 {
            uDialAnim?.textureValue = futrAniTex
            uDialPal?.textureValue = futrPalTex
        }
        else {
            uDialAnim?.textureValue = pastAniTex
            uDialPal?.textureValue  = pastPalTex
        }
    }

    // textures -----------------------------------------------------
    
    func updatePalTex() {
        
        let height = 3
        let size = CGSize(width:indexWidth, height:height)
        futrPalTex = SKTexture(data: Texture.makePal(indexWidth,height,dots.futr), size: size)
        pastPalTex = SKTexture(data: Texture.makePal(indexWidth,height,dots.past), size: size)
        recPalTex  = SKTexture(data: Texture.makePal(indexWidth,height,dots.futr, recHub: true), size: size)
    }
    
    func updateAniTex() {
        
        let frames  = Int(Anidex.animEnd.rawValue)
        let texSize = CGSize(width:indexWidth, height: frames)
        futrAniTex = SKTexture(data: Texture.makeAnim(frames, indexWidth, dayHour.days, dayHour.hours, dots.futr), size:texSize)
        pastAniTex = SKTexture(data: Texture.makeAnim(frames, indexWidth, dayHour.days, dayHour.hours, dots.past), size:texSize)
    }
    
    func updatePastFutr() {
        let isFuture = anim.sceneFrame == 0 ? anim.animNow.rawValue > 0 ? true : false :
            /**/       anim.sceneFrame  > 0 ? true : false

        if isFuture {
            uDialAnim?.textureValue = futrAniTex
            uDialPal?.textureValue = anim.animNow == .recSpoke ? recPalTex : futrPalTex
            dial.xScale = 1.0
        }
        else {
            uDialAnim?.textureValue = pastAniTex
            uDialPal?.textureValue = pastPalTex
            dial.xScale = -1.0
        }
    }

}
