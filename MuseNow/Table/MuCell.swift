//  MuCell.swift


import UIKit

class MuCell: UITableViewCell {
    
    var event : MuEvent!
    enum Highlighting { case unknown, high, low, forceHigh, forceLow, refresh }
    var highlighting = Highlighting.unknown
    var tableVC : UITableViewController!
    var height = CGFloat(44)

    func setHighlights(_ highlighting_:Highlighting, views:[UIView], borders:[UIColor], backgrounds:[UIColor], alpha:CGFloat, animated:Bool) {

        if  highlighting != highlighting_ {
            switch highlighting_ {
            case .refresh: break
            case .high, .forceHigh: highlighting = .high ; isSelected = true
            default:                highlighting = .low  ; isSelected = false
            }

            var border      : CGColor!
            var background  : CGColor!

            switch highlighting {
            case .high, .forceHigh: border = borders[1].cgColor ; background = backgrounds[1].cgColor
            default:                border = borders[0].cgColor ; background = backgrounds[0].cgColor
            }
            if animated {
                animateViews(views, border, background, alpha: alpha, duration: 0.25)
            }
            else {
                for view in views {
                    view.layer.borderColor = border
                    view.layer.backgroundColor = background
                    view.alpha = alpha
                }
            }
        }
        else {
            switch highlighting {
            case .high,.forceHigh: isSelected = true
            default:               isSelected = false
            }
        }
    }

    func setHighlight(_ highlighting_:Highlighting, animated:Bool = true) {
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
    
    func animateViews(_ views: [UIView],_ border:CGColor!,_ background:CGColor!, alpha:CGFloat, duration: Double) {

        for view in views {

            // animate border
            if border != nil {
                let borderAnim = CABasicAnimation(keyPath: "borderColor")
                let from = view.layer.presentation()?.value(forKey: "borderColor") ?? view.layer.borderColor!
                borderAnim.fromValue = from
                borderAnim.toValue   = border
                borderAnim.duration  = duration
                view.layer.add(borderAnim, forKey: "borders")
                view.layer.borderColor = border
            }

            // animate background
            if background != nil {
                let backAnim = CABasicAnimation(keyPath: "backgroundColor")
                let from = view.layer.presentation()?.value(forKey: "backgroundColor") ?? view.layer.borderColor!
                backAnim.fromValue = from
                backAnim.toValue   = background
                backAnim.duration  = duration
                view.layer.add(backAnim, forKey: "background")
                view.layer.backgroundColor = background
            }
            if alpha >= 0 {
                UIView.animate(withDuration: duration, animations: {
                    view.alpha = alpha
                })
            }
        }
    }


    //  UITouches ----------------------------------------------

    var startTime = TimeInterval(0)
    
    func touchCell(_ location: CGPoint, isExpandable:Bool = true) {
        print("\(#function) should override !!!")
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) { //print(#function)
        
        tableVC?.tableView.isScrollEnabled = false
        PagesVC.shared.scrollView?.isScrollEnabled = false
        
        startTime = (event?.timestamp)!
        super.touchesBegan(touches, with: event)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) { //print(#function)
        
        let deltaTime = (event?.timestamp)! - startTime
        let location = (touches.first?.location(in: self))!

        if deltaTime < 0.5 {
            
            touchCell(location)
        }
        super.touchesEnded(touches, with: event)
        
        tableVC?.tableView?.isScrollEnabled = true
        PagesVC.shared.scrollView?.isScrollEnabled = true
    }

}

