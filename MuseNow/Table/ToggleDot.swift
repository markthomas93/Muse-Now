import UIKit

class ToggleDot: UIView {
    
    var dot = UIView(frame: CGRect(x:11, y:11, width:14, height:14))
    var isOn = false
    var event : KoEvent!
    
    override init(frame:CGRect) {
        super.init(frame:frame)
        initToggleDot()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initToggleDot()
    }
    
     func initToggleDot() {
        
        // set border color for highl
        layer.cornerRadius = self.frame.height/2
        layer.borderColor = UIColor.black.cgColor
        layer.borderWidth = 1
        layer.masksToBounds = true
        
        // make dot
        dot.layer.cornerRadius = dot.frame.height/2
        dot.layer.masksToBounds = true
        dot.backgroundColor = .clear
        self.addSubview(dot)
    }
    func setMark(_ isOn_:Bool) {
        isOn = isOn_
        dot.backgroundColor = isOn ? .white : .clear
        event?.mark = isOn
    }
    func toggle() {
        setMark(!isOn)
    }
     
}

class ToggleCheck: UIView {
    
    var check : UIImageView!
    var event : KoEvent!
    
    override init(frame:CGRect) {
        super.init(frame:frame)
        initToggleDot()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initToggleDot()
    }
    
    func initToggleDot() {
    
        let height = self.frame.height
        
        // set border color for highl
        layer.cornerRadius = height/4
        layer.borderColor = UIColor.black.cgColor
        layer.borderWidth = 1
        layer.masksToBounds = true
        
        // make check
        check = UIImageView(image: UIImage(named: "icon-check.png")!)
        check.frame = CGRect(x:0, y:0, width:height, height:height)
        self.addSubview(check)
        
    }
    func setMark(_ isOn:Bool) {
        check.isHidden = !isOn
    }
    func toggle() {
        setMark(check.isHidden)
    }
    
}
