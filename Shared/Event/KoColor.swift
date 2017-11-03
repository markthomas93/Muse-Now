
import WatchKit
import EventKit

public enum TypeColor: UInt { case red,orange,yellow,green,blue,purple,violet,gray,white,clear}

class KoColor {
    
    class func makeColor32(_ red:CGFloat, _ green:CGFloat, _ blue:CGFloat) -> UInt32 {
        
        let rr = round(red*255.0)
        let gg = round(green*255.0)
        let bb = round(blue*255.0)
        
        let r = (UInt32(rr)&0xFF)<<16
        let g = (UInt32(gg)&0xFF)<<8
        let b = (UInt32(bb)&0xFF)
        return (r+g+b)
    }
    
    class func getUIColor( _ rgb: UInt32) -> UIColor {
        
        let b = CGFloat((rgb      ) & 0xFF)/255
        let g = CGFloat((rgb >>  8) & 0xFF)/255
        let r = CGFloat((rgb >> 16) & 0xFF)/255
        
        return UIColor(red:r, green:g, blue:b, alpha:1.0)
    }

    
    class func makeTypeColor(_ color_: TypeColor) -> UInt32 {
        
        switch color_ {
        case .red    : return makeColor32(1.0, 0.0, 0.0)
        case .orange : return makeColor32(1.0, 0.5, 0.0)
        case .yellow : return makeColor32(1.0, 1.0, 0.0)
        case .green  : return makeColor32(0.0, 1.0, 0.0)
        case .blue   : return makeColor32(0.2, 0.2, 1.0)
        case .purple : return makeColor32(0.5, 0.0, 1.0)
        case .violet : return makeColor32(1.0, 0.0, 1.0)
        case .gray   : return makeColor32(0.5, 0.5, 0.5)
        case .white  : return makeColor32(1.0, 1.0, 1.0)
        case .clear  : return makeColor32(1.0, 1.0, 1.0)
        }
    }
    
    class func colorFrom(cgColor: CGColor) -> UInt32 {
        
        let rgba = cgColor.components
        return makeColor32((rgba?[0])!,(rgba?[1])!,(rgba?[2])!)
    }
    
    class func colorFrom(event: EKEvent, _ type: KoType = .ekevent) -> UInt32 {
        if type == .routine {
            if let notes = event.notes {
                let colorNames = notes.regex("#color:[ ]*([A-Za-z]+)")
                if colorNames.count > 0,
                    let names = colorNames.first {
                    if names.count > 1 {
                        let name = names[1]
                        switch name {
                        case "red"      : return KoColor.makeTypeColor(.red)
                        case "orange"   : return KoColor.makeTypeColor(.orange)
                        case "yellow"   : return KoColor.makeTypeColor(.yellow)
                        case "green"    : return KoColor.makeTypeColor(.green)
                        case "blue"     : return KoColor.makeTypeColor(.blue)
                        case "purple"   : return KoColor.makeTypeColor(.purple)
                        case "violet"   : return KoColor.makeTypeColor(.violet)
                        case "gray"     : return KoColor.makeTypeColor(.gray)
                        case "white"    : return KoColor.makeTypeColor(.white)
                        default         : return KoColor.makeTypeColor(.gray)
                        }
                    }
                }
                let colorRGB = notes.regex("#color:[ #]*([0-9]{6,8}+)")
                if colorRGB.count > 0 {
                    //print ("#color:\(colorRGB[0][1])")
                }
            }
        }
        return colorFrom(cgColor:event.calendar.cgColor)
    }

    
}
