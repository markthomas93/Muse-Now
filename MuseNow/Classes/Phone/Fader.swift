import UIKit

class Fader: TouchForce {
    
    var value = Float(0.5)
    var thumb : UIView!
    var thumbR = CGFloat(16)
    var runway = CGFloat(16)
    let borderWidth = CGFloat(1)

    var updateFunc: CallFloat?
    var updateBegan: CallVoid?
    var updateEnded: CallVoid?
    
    convenience init (frame : CGRect,_ value_:Float) {
        self.init(frame : frame)
        value = value_
        initialize()
    }

    override init (frame : CGRect) {
        super.init(frame : frame)
        initialize()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }

    
    func initialize() {
        
        layer.cornerRadius    = frame.height/2
        layer.borderWidth     = borderWidth
        layer.backgroundColor = headColor.cgColor
        layer.borderColor     = UIColor.white.cgColor
        
        thumbR = frame.height/2 - borderWidth * 2
        
        thumb = UIView(frame: CGRect(x: borderWidth, y: 2*borderWidth, width: thumbR*2, height: thumbR*2))
        thumb.layer.cornerRadius    = thumbR
        thumb.layer.borderWidth     = borderWidth
        thumb.layer.backgroundColor = UIColor.gray.cgColor
        thumb.layer.borderColor     = UIColor.white.cgColor
        self.addSubview(thumb)

        runway = frame.size.width -  2*thumbR - 4*borderWidth
    }
    
    func setValue(_ value_:Float) {
        value = value_
        thumb.center.x = thumbR + 2*borderWidth + runway * CGFloat(value)
    }

    func updatePos(_ pos:CGPoint) {
        
        let width = frame.size.width
        let norm = pos.x/width
        value = Float(max(0.0, min(1.0, norm)))
        thumb.center.x = thumbR + 2*borderWidth + runway * CGFloat(value)
        updateFunc?(value)
    }
    
    // override Touching
    
    func setHighlight(on:Bool) {
        let nextAlpha: CGFloat = on ? 1.00 : 0.10
        let duration: Double   = on ? 0.25 : 1.00
        UIView.animate(withDuration: duration, animations: { self.alpha = nextAlpha })
    }
    
    override func began(_ pos: CGPoint,_ time: TimeInterval) {
        
        updateBegan?()
        Say.shared.updateDialog(nil, .phraseSlider, spoken:"fader", title:"fader", via:#function)
        updatePos(pos)
     }
    
    override func moved(_ pos: CGPoint, _ delta:CGPoint,_ time: TimeInterval) {

        updatePos(pos)
    }
    
    override func ended(_ pos: CGPoint, _ delta:CGPoint,_ time: TimeInterval) {

        updateEnded?()
        updatePos(pos)
    }
    
 }
