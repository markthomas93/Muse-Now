//  UIImage+Circle.swift

import UIKit

extension UIImage {
    
    class func circle(diameter: CGFloat, cgColor: CGColor) -> UIImage {
        
        UIGraphicsBeginImageContextWithOptions(CGSize(width: diameter, height: diameter), false, 0)
        let ctx = UIGraphicsGetCurrentContext()!
        ctx.saveGState()
        
        let rect = CGRect(x: 0, y: 0, width: diameter, height: diameter)
        ctx.setFillColor(cgColor)
        ctx.fillEllipse(in: rect)
        
        ctx.restoreGState()
        let img = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        return img
    }

    class func circle(diameter: CGFloat, color: UIColor) -> UIImage {

        return UIImage.circle(diameter:diameter, cgColor:color.cgColor)
    }

    // MARK: - Timeline Population
    func rotate(radians: CGFloat) -> UIImage {

        UIGraphicsBeginImageContext(size)

        let bitmap: CGContext = UIGraphicsGetCurrentContext()!
        bitmap.translateBy(x: size.width / 2, y: size.height / 2)
        bitmap.rotate(by: radians)
        bitmap.scaleBy(x: 1.0, y: -1.0)
        let origin = CGPoint(x: -size.width / 2, y: -size.width / 2)
        bitmap.draw(cgImage!, in: CGRect(origin: origin, size: size))
        let newImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!

        UIGraphicsEndImageContext()
        return newImage
    }


}
