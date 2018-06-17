
import SceneKit
import SpriteKit
import UIKit
import WatchKit

class Texture {

    static var nowHubIndex = 0

    /**
     Create lookup table texture to animate,
     where each row is a single point within an animation

     - Parameter frames: number of frames for anmation (240)
     - Parameter width:  width of palette (24*7 + 4) + 2 // rim and hub
     - Parameter days:   number of rotations (7)
     - Parameter hours:  number of hours/rotations (24)
     - Parameter dots:   each hour which may have marks

     - spokeDown     0 ..< 7     spoke down fade out center
     - spokeUp       7 ..< 14    end of single spoke back up
     - spokeFan     14 ..< 38    fan out 24 spokes for all hours
     - eachHour     38 ..< 206   each hour's spoke w fading contrail
     - wheelSpoke  206 ..< 213   main hour fade in wheel
     - wheelFade   213 ..< 220   dimm wheel to show only spokeUp
     - animEnd     220 ..< 240   end of animate (4 seconds)

     - these are indices into a palette created by makePal.
     */
    static func makeAnim(_ frames: Int, _ width: Int, _ days: Int, _ hours: Int, _ dots: [Dot] ) -> Data {

        nowHubIndex = (38*width + hours*days)*4 // when recording overlay a red dot

        var data = Data(count: frames * width * 4)
        let fill = width - (days * hours)
        if fill < 0 {
            Log("🎞 makeAnim width:\(width) < days:\(days) * hours:\(hours)")
            return data
        }

        /**
         Last two palette entries show active events for that hour
         - Parameter bytes: palette to fill
         - Parameter jjj: index into palette
         - Parameter hub: hour contains marked event
         - Parameter rim: hour contains unmarked event
         */
        func fillHubRim(_ bytes: UnsafeMutablePointer<UInt8>, _ jjj:Int, hub:UInt8, rim:UInt8) -> Int {
            
            var jj = jjj
            bytes[jj] = rim; bytes[jj+1]=0; bytes[jj+2]=0; bytes[jj+3]=255;  jj += 4  //rim
            bytes[jj] = hub; bytes[jj+1]=0; bytes[jj+2]=0; bytes[jj+3]=255;  jj += 4  //hub
            return jj
        }
        
        data.withUnsafeMutableBytes { (bytes: UnsafeMutablePointer<UInt8>) -> Void in
            
            // anim.x fade in with hour-for-all-days spokes
            var jj = Int(0)
            
            // animStart = 0,  // start of animation (spoke is shown up for current hour)

            // spokeDown  0 ..< 7,  // spoke down fade out center
            
            for dayi in 0 ..< days {
                
                for day in 0 ..< days {
                    for hour in 0 ..< hours {
                        bytes[jj] = UInt8(hour==0 && day >= dayi ? 255 : 0)
                        bytes[jj+1]=0; bytes[jj+2]=0; bytes[jj+3]=255
                        jj += 4
                    }
                }
                jj = fillHubRim(bytes,jj, hub:255, rim:0)
            }
            
            // spokeUp 7 ..< 14,  // end of single spoke back up
            
            for dayi in 0 ..< days {
                
                for day in 0 ..< days {
                    for hour in 0 ..< hours {
                        bytes[jj] = UInt8(hour==0 && day >= (7-dayi) ? 255 : 0)
                        bytes[jj+1]=0; bytes[jj+2]=0; bytes[jj+3]=255
                        jj += 4
                    }
                }
                jj = fillHubRim(bytes,jj, hub:255, rim:0)
            }
            
            let fanlo  = Float(0.2)
            
            // spokeFan 14 ..< 38  // fan out spokes for all hours with slight wheel fade
            
            for houri in 0 ..< hours {
                
                for _ in 0 ..< days {
                    for hour in 0 ..< hours {
                        if hour <= houri {
                            let fact = Float(hours-hour)/Float(hours)
                            let span = fanlo + fact*(1-fanlo)
                            bytes[jj] = UInt8(span * 255)
                        }
                        else {
                            bytes[jj] = 0
                        }
                        bytes[jj+1]=0; bytes[jj+2]=0; bytes[jj+3]=255
                        jj += 4
                    }
                }
                jj = fillHubRim(bytes,jj, hub:0, rim:255)
            }
            
            // eachHour   38 ..< 206  // each hour's under spoke and fading contrail

            for dayi in 0 ..< days {
                for houri in 0 ..< hours {
                    
                    let itemi = dayi * hours + houri
                    
                    for dayj in 0 ..< days {
                        for hourj in 0 ..< hours {
                            
                            let itemj = dayj * hours + hourj
                            let delta = itemj - itemi
                            
                            if houri == hourj && dayi <= dayj { bytes[jj] = 255 }
                            else if delta > 0 { bytes[jj] = UInt8(fanlo * 255) }
                            else if delta==0 {  bytes[jj]=UInt8(255) }
                            else {
                                let fact = 1/pow(2,Float(abs(delta))/24)
                                let span = fanlo + fact * (1 - fanlo)
                                bytes[jj]=UInt8(span*255)
                            }
                            bytes[jj+1]=0; bytes[jj+2]=0; bytes[jj+3]=255 // black
                            jj += 4
                        }
                    }
                    // fill rim and hub
                    let dot = dots[itemi]
                    if      dot.hasMark()           { jj = fillHubRim(bytes, jj, hub:255, rim:  0) }
                    else if max(0,dot.elapse0) < 60 { jj = fillHubRim(bytes, jj, hub:  0, rim:127) }
                    else                            { jj = fillHubRim(bytes, jj, hub:  0, rim:  0) }
                }
            }
            
            // wheelSpoke  206 ..< 213,  // main hour fade in wheel
            
            var prevRow = jj - width*4 // prevous row for fade-in
            
            for dayi in 0 ..< days {
                
                var ii = prevRow
                
                for day in 0 ..< days {
                    for hour in 0 ..< hours {
                        
                        bytes[jj] = UInt8(hour==0 && day >= (7-dayi) ? 255 : bytes[ii])
                        bytes[jj+1]=0; bytes[jj+2]=0; bytes[jj+3]=255
                        ii += 4
                        jj += 4
                    }
                }
                jj = fillHubRim(bytes,jj, hub:255, rim:0)
            }
            
            // wheelFade 213 ..< 220,  // complete dimmed wheel to show only spokeUp
            
            prevRow = jj - width * 4 // prevous row for fade-in
            
            for dayi in 0 ..< days {
                
                var ii = prevRow
                
                for day in 0 ..< days {
                    for hour in 0 ..< hours {
                        
                        bytes[jj] = hour==0 ? 255 : day >= (6-dayi) ? 0 : bytes[ii]
                        bytes[jj+1]=0; bytes[jj+2]=0; bytes[jj+3]=255
                        ii += 4
                        jj += 4
                    }
                }
                jj = fillHubRim(bytes, jj, hub:255, rim:0)
           }
            // animEnd 220 ..< 240   // end of animate (4 seconds)
            
            prevRow = jj - width * 4 // prevous row for fade-in
            
            for _ in 220 ..< 240 {
                
                var ii = prevRow
                
                for _ in 0 ..< width-2 {
                    
                    bytes[jj]   = bytes[ii]
                    bytes[jj+1] = bytes[ii+1]
                    bytes[jj+2] = bytes[ii+2]
                    bytes[jj+3] = bytes[ii+3]
                    ii += 4
                    jj += 4
                }
                jj = fillHubRim(bytes,jj, hub:255,rim:0)
            }
        }
        //printData(data, frames, days, hours, 0)
        return data
    }
    /**
     Inverse of makeAnim, show spoke for current hour and spiral inward towards a mark in the future.
     To render a complication, but since complications can be rendered in the GPU while app is in background
     this palette is totally useless.

     - note: Keep around, if you decide to prerender all 168 posible countdowns as static images.
     Otherwise, delete.
     */
    static func makeCountDown(_ width:Int, _ days: Int, _ hours: Int) -> Data {

        var frames = days * hours
        var data = Data(count: frames * width * 4)
        let fill = width - (days * hours)
        if fill < 0 {
            Log("🎞 makeCountDown width:\(width) < days:\(days) * hours:\(hours)")
            return data
        }

        /**
         Last two palette entries show active events for that hour
         - Parameter bytes: palette to fill
         - Parameter jj_: index into palette
         - Parameter hub: hour contains marked event
         - Parameter rim: hour contains unmarked event
         */
        func fillHubRim(_ bytes: UnsafeMutablePointer<UInt8>, _ jj_:Int, hub:UInt8, rim:UInt8) -> Int {

            var jj = jj_
            bytes[jj] = rim; bytes[jj+1]=0; bytes[jj+2]=0; bytes[jj+3]=255;  jj += 4  //rim
            bytes[jj] = hub; bytes[jj+1]=0; bytes[jj+2]=0; bytes[jj+3]=255;  jj += 4  //hub
            return jj
        }

        data.withUnsafeMutableBytes { (bytes: UnsafeMutablePointer<UInt8>) -> Void in

            // anim.x fade in with hour-for-all-days spokes
            var jj = Int(0)

            // eachHour   0 ..< 186  // each hour's under spoke and fading contrail

            for dayi in 0 ..< days {
                for houri in 0 ..< hours {

                    let itemi = dayi * hours + houri

                    for dayj in 0 ..< days {
                        for hourj in 0 ..< hours {

                            let itemj = dayj * hours + hourj
                            let delta = itemj - itemi
                            bytes[jj] = (delta <= 0 || (houri == 0 && dayi <= dayj)) ? 255 : 0
                            bytes[jj+1]=0; bytes[jj+2]=0; bytes[jj+3]=255 // black
                            jj += 4
                        }
                    }
                    // fill rim and hub
                    jj = fillHubRim(bytes, jj, hub:255, rim:  0)
                }
            }
        }
        return data
    }

    func printData(_ data: Data, _ frames: Int, _ days: Int, _ hours: Int, _ offset: Int) {

        data.withUnsafeBytes { (bytes: UnsafePointer<UInt8>) -> Void in

            var jj = Int(0)
            
            for frame in 0 ..< frames {
                
                print("\n\(frame):", terminator:"")
                
                for _ in 0 ..< days {
                    
                    print(" ", terminator: "")
                    
                    for _ in 0 ..< hours {
                        
                        let rgb = bytes[jj + offset]
                        
                        jj += 4
                        
                        if (rgb==0) {
                            print(".", terminator: "")
                        }
                        else {
                            print("\(rgb/26)", terminator: "")
                        }
                    }
                }
            }
        }
    }

    /**
     Create palette rows
     - Parameter width: 24*7 + 2; 168 hours for week plus hub and rim
     - Parameter height: 3 rows: rainbow, mono, event
     - Parameter dots:  (-168...168) for past and future week dots
     - Parameter recHub:  true if coloring hub red for recording
     */

    static func makePal(_ width: Int,_ height:Int, _ dots: [Dot], recHub:Bool = false ) -> Data {

        let rgbaSize = 4 // for rgba values 0...255
        var data = Data(count: width * height * rgbaSize)
        
        data.withUnsafeMutableBytes { (bytes: UnsafeMutablePointer<UInt8>) -> Void in
            
            var ii = Int(0)
            
            // rainbow palette ----------------------------------

            for i in 0 ..< width-2 {
                
                let hue = CGFloat(i)/400 // royg - not roygbiv
                let color = SKColor(hue: hue, saturation: 1.0, brightness: 1.0, alpha: 1.0)
                let comp = color.cgColor.components
                
                let r = UInt8(comp![0]*255.0)
                let g = UInt8(comp![1]*255.0)
                let b = UInt8(comp![2]*255.0)
                //print ("i:\(i) rgb(\(r),\(g),\(b))")
                bytes[ii+0] = r; bytes[ii+1] = g; bytes[ii+2] = b; bytes[ii+3] = 255; ii += 4
            }
            
            // last 2 color index i white
            bytes[ii+0] = 255; bytes[ii+1] = 255; bytes[ii+2] = 255; bytes[ii+3] = 255; ii += 4
            bytes[ii+0] = 255; bytes[ii+1] = 255; bytes[ii+2] = 255; bytes[ii+3] = 255; ii += 4
            
            // monochrome palette -----------------------------------

            for _ in 0 ..< width-2 {
                bytes[ii+0] = 255; bytes[ii+1] = 255; bytes[ii+2] = 255; bytes[ii+3] = 255; ii += 4
            }
            // last 2 create hub and rim, red for recording texture, white for normal textures
            if recHub {
                for _ in width-2 ..< width {
                    bytes[ii+0] = 255; bytes[ii+1] = 0; bytes[ii+2] = 0; bytes[ii+3] = 255; ii += 4
                }
            }
            else {
                for _ in width-2 ..< width {
                    bytes[ii+0] = 255; bytes[ii+1] = 255; bytes[ii+2] = 255; bytes[ii+3] = 255; ii += 4
                }
            }
            // event color palette -----------------------------------

            for jj in 0 ..< 24*7 {

                let rgb = dots[jj].rgb
                bytes[ii+0] = UInt8(rgb >> 16 & 0xFF)
                bytes[ii+1] = UInt8(rgb >>  8 & 0xFF)
                bytes[ii+2] = UInt8(rgb       & 0xFF)
                bytes[ii+3] = UInt8(0xFF)
                ii += 4
            }
            for _ in 24*7 ..< width {

                bytes[ii+0] = 0xFF
                bytes[ii+1] = 0xFF
                bytes[ii+2] = 0xFF
                bytes[ii+3] = 0xFF
                ii += 4
            }
        }
        return data
    }

    
    static func pokePal(data:inout Data, _ width: Int,_ height:Int, hour:Int, _ rgb: UInt32) {

        data.withUnsafeMutableBytes { (bytes: UnsafeMutablePointer<UInt8>) -> Void in
            var ii = width * 4 * 2 // skip first two rows times size of each column
            ii += hour * 4
            bytes[ii+0] = UInt8(rgb >> 16 & 0xFF)
            bytes[ii+1] = UInt8(rgb >>  8 & 0xFF)
            bytes[ii+2] = UInt8(rgb       & 0xFF)
            bytes[ii+3] = UInt8(0xFF)
        }
    }

    /**
     Create a series of dots that spiral inward
     - Parameter days:       number of full rotations
     - Parameter hour:      number of dots per rotation
     - Parameter size:      size of texture
     - Parameter lineWidth:  size of clipping mask border line
     - Parameter dotFactor:  shrink the dot, 1.0: biggest dots are touching
     - Parameter maskFactor: should be smaller than dotFactor to clip jaggies
     - note: Returns Output:[dialTex,maskTex]
     - dialTex: each dot is a pure color used as an index
     - maskTex: mask for dialTex to allow for antialised border
     */
    static func makeTextures(_ days:Int, hour:Int, _ size:CGSize, margin:CGFloat, lineWidth: CGFloat, dotFactor: CGFloat, maskFactor: CGFloat) -> [SKTexture?] {
        
        let center = CGPoint(x: size.width / 2, y: size.height / 2)
        let radius =  min(size.width, size.height)/2 - margin
        var textures : [SKTexture] = []
        
        var minRad = CGFloat(999)
        
        @discardableResult
        func makeDot(_ context:CGContext, _ fr˚: CGFloat, _ factor: CGFloat, _ count: CGFloat, _ mode: CGPathDrawingMode) -> CGFloat {
            
            let fr = dotRadius(radius, fr˚, 0, dump:true)
            let frA = CGFloat(CGFloat(Pi2) * (fr˚ + 270) / 360) // from angle
            let pos = PolarPoint2(center, frA, fr.cenRadius)   // from point
            let rad = fr.dotRadius * factor
            minRad = min(fr.cenRadius-rad,minRad)
            
            let path = CGMutablePath()
            path.addArc(center: pos, radius: rad, startAngle: 0.0, endAngle: CGFloat(Pi2), clockwise: true)
            context.addPath(path)
            context.setFillColor(UIColor(white: (count/255.0), alpha:1.0).cgColor)
            context.drawPath(using: mode)
            
            let innerRadius =  fr.cenRadius - rad
            return innerRadius
        }

        func makeHub (_ context:CGContext, _ minRad: CGFloat, _ count: CGFloat) {
            
            let path = CGMutablePath()
            path.addArc(center: center, radius: minRad, startAngle: 0.0, endAngle: CGFloat(Pi2), clockwise: true)
            context.addPath(path)
            context.setFillColor(UIColor(white: (count/255.0), alpha:1.0).cgColor)
            context.drawPath (using: CGPathDrawingMode.fill)
        }

        func makeRim (_ context:CGContext, _ maxRad: CGFloat, _ minRad: CGFloat, _ count: CGFloat) {
            
            var path = CGMutablePath()
            path.addArc(center: center, radius: maxRad, startAngle: 0.0, endAngle: CGFloat(Pi2), clockwise: true)
            context.addPath(path)
            context.setFillColor(UIColor(white: (count/255.0), alpha:1.0).cgColor)
            context.drawPath (using: CGPathDrawingMode.fill)
            
            path = CGMutablePath()
            path.addArc(center: center, radius: minRad, startAngle: 0.0, endAngle: CGFloat(Pi2), clockwise: true)
            context.addPath(path)
            context.setFillColor(UIColor.black.cgColor)
            context.drawPath (using: CGPathDrawingMode.fill)
        }
        
        // dailImg is main
        var rimIndex = CGFloat(0)
        var hubIndex = CGFloat(0)
        var rimRado = 1 - Phi⁻³ // outer radius for rim
        var rimRadi = 1 - Phi⁻² // inner radius for rim
        var hubRad  = 1 - Phi⁻² // outer radius for hub

        // for a separate hub texture that is inset inside of dial
        var rimMaskRado : CGFloat!
        var rimMaskRadi : CGFloat!
        var hubMaskRad  : CGFloat!


        let dialMainImg = UIImage.ImageContext(size, completion: { (image,context) in
            
            context.setShouldAntialias(false)
            var hourIndex = CGFloat(0)
            
            for fr˚:CGFloat in stride(from: 0, to: 360*CGFloat(days), by: 15) {
                
                let innerRad = makeDot(context, fr˚, dotFactor, hourIndex, .fill)
                minRad = min(innerRad, minRad)
                hourIndex += 1
            }
            rimIndex = hourIndex
            hubIndex = hourIndex + 1
            rimRado *= minRad // outer radius for rim
            rimRadi *= minRad // inner radius for rim
            hubRad  *= minRad // outer radius for hub
            
            makeRim(context, rimRado, rimRadi, rimIndex)
            makeHub(context, hubRad,           hubIndex)
        })
        textures.append(SKTexture(image:dialMainImg))
        
        // dialMaskImg is a mask for antialiased border
        let dialMaskImg = UIImage.ImageContext(size, completion: { (image,context) in
            
            context.setShouldAntialias(true)
            let whiteIndex = CGFloat(255.0)
            
            for fr˚:CGFloat in stride(from: 0, to: 360*CGFloat(days), by: 15) {
                
                makeDot(context, fr˚, maskFactor, whiteIndex, .fillStroke)
            }

            rimMaskRado = rimRado - lineWidth
            rimMaskRadi = rimRadi + lineWidth
            hubMaskRad  = hubRad  - lineWidth

            makeRim(context, rimMaskRado, rimMaskRadi, rimIndex)
            makeHub(context, hubMaskRad,               hubIndex)
        })
        textures.append(SKTexture(image:dialMaskImg))

        // make hub textures to inset within dial
        let hubSize = CGSize(width: trunc(rimRado+1), height: trunc(rimRado+1))
        let hubMainImg = UIImage.ImageContext(hubSize, completion: { (image,context) in

            makeRim(context, rimRado, rimRadi, rimIndex)
            makeHub(context, hubRad,           hubIndex)
        })
        textures.append(SKTexture(image:hubMainImg))

        let hubMaskImg = UIImage.ImageContext(hubSize, completion: { (image,context) in
            makeRim(context, rimMaskRado, rimMaskRadi, rimIndex)
            makeHub(context, hubMaskRad,               hubIndex)
        })
        textures.append(SKTexture(image:hubMaskImg))

        return textures
    }

    /**
     Create a series of dots that spiral inward
     - Parameter days:       number of full rotations
     - Parameter hour:      number of dots per rotation
     - Parameter size:      size of texture
     - Parameter lineWidth:  size of clipping mask border line
     - Parameter dotFactor:  shrink the dot, 1.0: biggest dots are touching
     - Parameter maskFactor: should be smaller than dotFactor to clip jaggies
     - note: returns Output:[dialTex,maskTex]
     - dialTex: each dot is a pure color used as an index
     - maskTex: mask for dialTex to allow for antialised border
     */
    static func makeComplication(_ days:Int,_ size:CGSize, lineWidth: CGFloat, maskFactor: CGFloat, margin: CGFloat) -> [SKTexture] {

        let center = CGPoint(x: size.width / 2, y: size.height / 2)
        let radius =  min(size.width, size.height)/2 - margin
        var spokes : [SKTexture] = []

        var minRad = CGFloat(999)

        @discardableResult
        func makeDot(_ context:CGContext, _ fr˚: CGFloat, _ factor: CGFloat, _ alpha: CGFloat, _ mode: CGPathDrawingMode) -> CGFloat {

            let fr = dotRadius(radius, fr˚, 0, dump:true)
            let frA = CGFloat(CGFloat(Pi2) * (fr˚ + 270) / 360) // from angle
            let pos = PolarPoint2(center, frA, fr.cenRadius)   // from point
            let rad = fr.dotRadius * factor * alpha // shrink by color for 1-bit alpha
            minRad = min(fr.cenRadius-rad,minRad)

            let path = CGMutablePath()
            path.addArc(center: pos, radius: rad, startAngle: 0.0, endAngle: CGFloat(Pi2), clockwise: true)
            context.addPath(path)

            context.setFillColor(UIColor(white: alpha, alpha:alpha).cgColor)
            context.drawPath(using: mode)
            
            let innerRadius =  fr.cenRadius - rad
            return innerRadius
        }
        
        func makeRedRimHub (_ context:CGContext, _ maxRad: CGFloat, _ minRad: CGFloat) {

            var path = CGMutablePath()
            path.addArc(center: center, radius: maxRad, startAngle: 0.0, endAngle: CGFloat(Pi2), clockwise: true)
            context.addPath(path)
            context.setFillColor(UIColor.red.cgColor)
            context.drawPath (using: CGPathDrawingMode.fill)

            path = CGMutablePath()
            path.addArc(center: center, radius: minRad, startAngle: 0.0, endAngle: CGFloat(Pi2), clockwise: true)
            context.addPath(path)
            context.setFillColor(UIColor.clear.cgColor)
            context.drawPath (using: CGPathDrawingMode.fill)
        }

        let wheelImg = UIImage.ImageContext(size, completion: { (image,context) in
            
            context.setShouldAntialias(true)

            for fr˚:CGFloat in stride(from: 360*CGFloat(days)-15, through: 0, by: -15) {

                let frMod = fr˚.truncatingRemainder(dividingBy: 360)
                let fr10 = (1 - (fr˚.truncatingRemainder(dividingBy: 360)/360)) // from 1 to 0

                let alpha = frMod == 0 ? CGFloat(0.75)
                    : fr˚ <= 360 ? 0.4 + 0.4 * fr10 // .8 to .4
                        /**/     : 0.2 + 0.2 * fr10 // .4 to .2
                let innerRad = makeDot(context, fr˚, maskFactor, alpha, .fillStroke)
                minRad = min(innerRad, minRad)
            }
            let _ = makeDot(context, 0, maskFactor, 1.0, .fillStroke)

        })

        let hubImg = UIImage.ImageContext(size, completion: { (image,context) in

            let rimRado = 1 - Phi⁻³ // outer radius for rim
            let rimRadi = 1 - Phi⁻² // inner radius for rim

            makeRedRimHub(context, rimRadi*minRad, rimRado*minRad)
        })
        let bothImg = wheelImg.plus(hubImg)

        return [SKTexture(image:bothImg!),
                SKTexture(image:wheelImg),
                SKTexture(image:hubImg)]
    }
    
}

