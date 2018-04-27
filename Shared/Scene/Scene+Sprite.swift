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
        //var dbgMask = Texture.makeDialMask(5, hour:0, size, margin:8, lineWidth:0.50, dotFactor: 0.33, maskFactor: 0.50) as! [SKTexture]
        let size =  CGSize(width:1024,height:1024) // CGSize(width:512,height:512)
        var dbgMask = Texture.makeDialMask(7, hour:0, size, margin:40,lineWidth:0.25, dotFactor: 0.62, maskFactor: 0.50) as! [SKTexture]
        let img0 = dbgMask[0].cgImage()
        let img1 = dbgMask[1].cgImage()
        #endif
    }
    func initSprite() {

        complications = Texture.makeComplication(dayHour.days, size, lineWidth:0.125, maskFactor:0.90, margin:16)
        dialMask = Texture.makeDialMask(dayHour.days, hour:0, size, margin:8, lineWidth:0.25, dotFactor: 0.62, maskFactor: 0.50) as! [SKTexture]
        sprite = SKSpriteNode(texture: dialMask[0], color: .black, size:size)
        sprite.position = CGPoint(x:center.x, y:center.y)
        sprite.color = .black

        uAnim  = SKUniform(name:"u_anim",  texture:futrAniTex)
        uMask  = SKUniform(name:"u_mask",  texture:dialMask[1])
        uPal   = SKUniform(name:"u_pal",   texture:futrPalTex)
        uFrame = SKUniform(name:"u_frame", float:0.0)
        uFade  = SKUniform(name:"u_fade",  float:1.0)
        uCount = SKUniform(name:"u_count", float:Float(indexWidth))

        updatePalTex()
        updateAniTex()

        uAnim?.textureValue = futrAniTex
        uPal?.textureValue = futrPalTex

        dialShader = SKShader(fileNamed: "Dial.fsh")
        
        dialShader.addUniform(uMask)
        dialShader.addUniform(uPal)
        dialShader.addUniform(uAnim)
        dialShader.addUniform(uFrame)
        dialShader.addUniform(uFade)
        dialShader.addUniform(uCount)

        sprite.shader = dialShader
        addChild(sprite)

        dayHour.updateTime() // set reference for current hour and day
        sprite.zRotation = CGFloat(Double(36-dayHour.hour0) / 24.0 * (2*Double.pi))
    }
       

    /**
     Flip horizonally the dot index texture, which is used for both past and future.
     Replace the color palette to reflect past or future hours
     - via: animOut
     */
    func updateSprite(xScale:CGFloat) {
        
        if sprite.xScale != xScale {
            sprite.xScale = xScale
            updateUniforms()
        }
    }

    func updateUniforms() {
        if sprite.xScale > 0 {
            uAnim?.textureValue = futrAniTex
            uPal?.textureValue = futrPalTex
        }
        else {
            uAnim?.textureValue = pastAniTex
            uPal?.textureValue  = pastPalTex
        }

    }
    // textures -----------------------------------------------------
    
    func updatePalTex() {
        
        let height = 3
        let size = CGSize(width:indexWidth, height:height)
        futrPalTex = SKTexture(data: Texture.makePal(indexWidth,height,dots.future), size: size)
        pastPalTex = SKTexture(data: Texture.makePal(indexWidth,height,dots.past  ), size: size)
        recPalTex = SKTexture(data: Texture.makePal(indexWidth,height,dots.future, recHub: true), size: size)
    }
    
    func updateAniTex() {
        
        let frames  = Int(Anidex.animEnd.rawValue)
        let texSize = CGSize(width:indexWidth, height: frames)
        futrAniTex = SKTexture(data: Texture.makeAnim(frames, indexWidth, dayHour.days, dayHour.hours, dots.future), size:texSize)
        pastAniTex = SKTexture(data: Texture.makeAnim(frames, indexWidth, dayHour.days, dayHour.hours, dots.past),   size:texSize)
    }
    
    func updatePastFutr() {
        let isFuture = anim.sceneFrame == 0 ? anim.animNow.rawValue > 0 ? true : false :
            /**/       anim.sceneFrame  > 0 ? true : false

        if isFuture {
            uAnim?.textureValue = futrAniTex
            uPal?.textureValue = anim.animNow == .recSpoke ? recPalTex : futrPalTex
            sprite.xScale = 1.0
        }
        else {
            uAnim?.textureValue = pastAniTex
            uPal?.textureValue = pastPalTex
            sprite.xScale = -1.0
        }

//        if animNow.rawValue > 0 { uAnim?.textureValue = futrAniTex ; uPal?.textureValue = futrPalTex ; sprite.xScale =  1.0 }
//        else                    { uAnim?.textureValue = pastAniTex ; uPal?.textureValue = pastPalTex ; sprite.xScale = -1.0 }
    }

}
