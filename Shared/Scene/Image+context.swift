import UIKit
import SceneKit
import SpriteKit

extension UIImage {
    
    class func ImageContext(_ size:CGSize, completion:(_ image:UIImage,_ context:CGContext)->Void) -> UIImage {
        
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        var image   = UIGraphicsGetImageFromCurrentImageContext()
        let context = UIGraphicsGetCurrentContext()!
        
        completion(image!,context)
        
        image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        context.setFillColor(SKColor.clear.cgColor)
        context.fill(CGRect(x:0, y:0, width:size.width, height: size.height))
        
        return image!
    }

    func plus(_ img:UIImage) -> UIImage! {

        UIGraphicsBeginImageContext(self.size)
        let rect = CGRect(x:0 ,y:0, width:size.width, height:size.height)
        self.draw(in: rect)
        img.draw(in: rect)

        let newImg = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return  newImg

    }
}
