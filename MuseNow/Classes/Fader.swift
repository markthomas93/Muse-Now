import UIKit

class Fader: TouchForce {
    
    var value = Float(0.5)
    var thumb : UIView!
    var thumbR = CGFloat(16)
    var runway = CGFloat(16)
    let borderWidth = CGFloat(1)
    var tableView : UITableView!
    
    override init(frame : CGRect) {
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
        initFromSettings()
        self.alpha = 0.5
    }
    
     func initFromSettings() {
        value = Settings.shared.getValueForKey("dialColor") as! Float
        thumb.center.x = thumbR + 2*borderWidth + runway * CGFloat(value)
    }
    
    func updatePos(_ pos:CGPoint) {
        
        let width = frame.size.width
        let norm = pos.x/width
        value = Float(max(0.0, min(1.0, norm)))
        thumb.center.x = thumbR + 2*borderWidth + runway * CGFloat(value)
        
        Actions.shared.dialColor(value, isSender: true)
        
        let phrase = String(format:"%.2f",value)
        Say.shared.updateDialog(nil, type:.saySlider, spoken:phrase, title:phrase)
    }
    
    // override Touching
    
    func setHighlight(on:Bool) {
        let nextAlpha: CGFloat = on ? 1.00 : 0.10
        let duration: Double   = on ? 0.25 : 1.00
        UIView.animate(withDuration: duration, animations: { self.alpha = nextAlpha })
    }
    
    override func began(_ pos: CGPoint,_ time: TimeInterval) {
        
        tableView?.isScrollEnabled = false
        PagesVC.shared.scrollView?.isScrollEnabled = false
        
        Say.shared.updateDialog(nil, type:.saySlider, spoken:"fader", title:"fader")
        setHighlight(on:true)
        updatePos(pos)
     }
    
    override func moved(_ pos: CGPoint, _ delta:CGPoint,_ time: TimeInterval) {

        updatePos(pos)
    }
    
    override func ended(_ pos: CGPoint, _ delta:CGPoint,_ time: TimeInterval) {

        updatePos(pos)
        setHighlight(on: false)
        
        tableView?.isScrollEnabled = true
        PagesVC.shared.scrollView?.isScrollEnabled = true
    }
    
 }
