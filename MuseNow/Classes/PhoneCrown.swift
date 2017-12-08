 import UIKit
 
 protocol PhoneCrownDelegate {
    func phoneCrownUpdate()
    func phoneCrownDeltaRow(_ deltaRow: Int,_ isRight:Bool)
    func phoneCrownToggle(_ isRight:Bool)
 }

class PhoneCrown: TouchForce {

    static var shared: PhoneCrown!
    var twin : PhoneCrown!
    var updating = false
    
    var delegate: PhoneCrownDelegate!
    var actions = Actions.shared
    
    let grooves = 5 // number of dots for crown, between 3...9, higher number will switch rows with less movement
    var maxOffset = CGFloat(1)
    var crownSize = CGSize(width:0, height:0)
    var crownOffset = CGPoint(x:0,y:0)
    var dimmed = true
    var prevOffsetY = CGFloat(0)
    
    enum Direction: UInt8 { case unknown, past, future }
    var direction : Direction = .unknown
    var isRight = true
    var lastX = CGFloat(0)
    
    convenience init (left:CGRect, right:CGRect,_ delegate_:PhoneCrownDelegate! ) {

        self.init(frame: left)

        PhoneCrown.shared = self // this is a departure from normal Singleton init

        initialize()
        delegate = delegate_
        isRight = false

        twin = PhoneCrown(frame: right)
        twin.initialize()
        twin.delegate = delegate_
        twin.isRight = true
        twin.twin = self
    }

    /**
    Each TableVC will use the phoneCrown to navigate up and down between cells. So, each will change the PhoneCrownDelegate.
     - via: [Tree,Edit]TableVC.viewWillAppear()
     */
    func setDelegate(_ delegate_:PhoneCrownDelegate) {
        delegate = delegate_
        if let twin = twin {
            twin.delegate = delegate_
        }
    }



    func initialize() {
        
        backgroundColor = UIColor.black
        
        crownSize = CGSize(width:  frame.size.width  * Phi⁻²,
                           height: frame.size.height * Phi⁻¹)
        
        crownOffset = CGPoint(x: (frame.size.width  - crownSize.width)  / 2,
                              y: (frame.size.height - crownSize.height) / 2)
        
        maxOffset = crownSize.height / CGFloat(grooves)
        
        dimmed = true
     }
    
     override func draw(_ rect: CGRect) {
        
        let grooveH = crownSize.height / CGFloat(grooves) / 2
        let centerX = crownSize.width / 2 + crownOffset.x
        let centerY = crownSize.height / 2 + crownOffset.y
        let divOfs = deltaY / maxOffset
        let offsetY = (divOfs - floor(divOfs)) * maxOffset
        if dimmed   { UIColor.darkGray.set() }
        else        { UIColor.white.set() }
        
        //printLog (String(format:"deltaY: %.1f mod %.1f -> divOfs: %.1f", deltaY, maxOffset, divOfs))
        for groove in 0 ..< grooves {
            
            let groveY = grooveH * CGFloat(groove*2) + crownOffset.y + offsetY
            let pos = CGPoint(x:centerX, y: groveY)
            let delta =  abs(centerY - pos.y)
            let rad = grooveH * (1 - delta / crownSize.height) * Phi⁻¹
            
            let path = UIBezierPath()
            path.addArc(withCenter: pos, radius: rad, startAngle: 0.0, endAngle: 2*CGFloat.pi, clockwise: true)
            path.stroke()
        }
        prevOffsetY = offsetY
    }

    var deltaY = CGFloat(0)
    var deltaYY = CGFloat(0)
    var prevDeltaRow = 0

    /**
     User sliding finger moves to next/prev row
     - via: PhoneCrown.[moved,ended]
     note: moving back and forth accross start line would normally feels like a skipped beat.
     Instead, wait for first delta and set that as the dividing line.
     Thus, you need to move twice the distance, which has an engaging theshold feel
     */
    func updateDelta (_ delta: CGPoint) {
        
        deltaY = delta.y - deltaYY // used by draw routine
        let nextDeltaRow = Int(deltaY / maxOffset)
        
        if prevDeltaRow != nextDeltaRow {
            let deltaCell =  prevDeltaRow - nextDeltaRow
            if deltaYY == 0 {
                deltaYY = deltaY
                return
            }
            //printLog ("\(#function) deltaY:\(deltaY) deltaYY:\(deltaYY) row:\(prevDeltaRow) -> \(nextDeltaRow)")
            
            delegate.phoneCrownDeltaRow(deltaCell, isRight)
            Haptic.play(.click)
        }
        prevDeltaRow = nextDeltaRow
    }
    
    //? Touching superclass overrides left and right side are synchonized with each other

    // began
    override func began(_ pos: CGPoint,_ time: TimeInterval) {
        
        if !updating {
            updating = true
            lastX = pos.x + self.frame.origin.x
            twin?.beganSlave()
            delegate.phoneCrownUpdate()
            beganSlave()
            
            updating = false
        }
    }
    func beganSlave () {
        
        deltaY = 0
        deltaYY = 0
        prevDeltaRow = 0
        dimmed = false
        setNeedsDisplay()
        UIView.animate(withDuration: 0.25, delay: 0, options: .allowUserInteraction, animations: {self.alpha = 1.0 }, completion:nil)
    }

    // moved
    override func moved(_ pos: CGPoint,_ delta: CGPoint,_ time: TimeInterval) {
        if !updating {
            updating = true
            lastX = pos.x + self.frame.origin.x
            twin?.movedSlave()
            updateDelta(delta)
            twin?.deltaY = deltaY
            movedSlave()
            updating = false
        }
    }
    func movedSlave() {
        setNeedsDisplay()
    }
    // ended
    override func ended(_ pos: CGPoint,_ delta: CGPoint,_ time: TimeInterval) {
        
        if !updating {
            updating = true
            lastX = pos.x + self.frame.origin.x
            twin?.endedSlave()
            endedSlave()
            updating = false
        }
    }
    func endedSlave() {
        dimmed = true
        setNeedsDisplay()
        UIView.animate(withDuration: 2.00, delay: 0, options: .allowUserInteraction,
                       animations: {self.alpha = 0.50 }, completion:nil)
    }
   
    // singleTap: toggle mark for current row
    
    override func singleTap(){
        printLog ("👆 PhoneCrown::\(#function)")
        let myDistance = abs(lastX - center.x)
        let twinDistance = abs(lastX - twin.center.x)
        let sendRight = myDistance < twinDistance ? isRight : twin.isRight
        delegate.phoneCrownToggle(sendRight)
    }
    
    override func forceTap(_ isForceOn: Bool) {
        if isForceOn {
            printLog ("👆 PhoneCrown::\(#function)")
            singleTap()
        }
    }
 }
