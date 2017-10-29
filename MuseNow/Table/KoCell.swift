//  KoCell.swift


import UIKit

class KoCell: UITableViewCell {
    
    var event : KoEvent!
    var isHighlight = false
    var tableView : UITableView!

    func setHighlight(_ isHighlight_:Bool, animated:Bool = true) {
        //assert("must override this")
    }
   
    func animateBorderColor(_ view: UIView,_ frColor: CGColor,_ toColor: CGColor, duration: Double) {
        
        let animation:CABasicAnimation = CABasicAnimation(keyPath: "borderColor")
        animation.fromValue = frColor
        animation.toValue   = toColor
        animation.duration  = duration
        view.layer.add(animation, forKey: "color")
        view.layer.borderColor = toColor
    }
    
    func animateViews(_ views: [UIView],_ borders:[CGColor],_ backgrounds:[CGColor], _ index:Int, duration: Double) {
        
        for view in views {
            
            // animate border
            let border = CABasicAnimation(keyPath: "borderColor")
            border.fromValue = borders[index^1]
            border.toValue   = borders[index]
            border.duration  = duration
            view.layer.add(border, forKey: "borders")
            view.layer.borderColor = borders[index]
 
            // animate background
            let background = CABasicAnimation(keyPath: "backgroundColor")
            background.fromValue = backgrounds[index^1]
            background.toValue   = backgrounds[index]
            background.duration  = duration
            view.layer.add(background, forKey: "background")
            view.layer.backgroundColor = backgrounds[index]
        }
    }
    

    //  UITouches ----------------------------------------------

    var startTime = TimeInterval(0)
    
    func touchTitle() { } // print("\(#function) should override !!!") }
    func touchMark()  { } // print("\(#function) should override !!!") }
   
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) { //print(#function)
        
        tableView?.isScrollEnabled = false
        PagesVC.shared.scrollView?.isScrollEnabled = false
        
        startTime = (event?.timestamp)!
        super.touchesBegan(touches, with: event)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) { //print(#function)
        
        let deltaTime = (event?.timestamp)! - startTime
        let location = (touches.first?.location(in: self))!
        let toggleX = frame.size.width -  frame.size.height*1.618
        
        if deltaTime < 0.5 {
            
            if location.x > toggleX { touchMark() }
            else                    { touchTitle() }
        }
        super.touchesEnded(touches, with: event)
        
        tableView?.isScrollEnabled = true
        PagesVC.shared.scrollView?.isScrollEnabled = true
    }

}

