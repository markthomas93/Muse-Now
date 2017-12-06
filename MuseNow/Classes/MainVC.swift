
import UIKit
import SceneKit
import SpriteKit
import AudioToolbox
import WatchKit

class MainVC: UIViewController {
    
    let session  = Session.shared
    let active   = Active.shared
    let memos    = Memos.shared
    let marks    = Marks.shared
    let anim     = Anim.shared
    let dots     = Dots.shared
    let pagesVC  = PagesVC.shared
    let actions  = Actions.shared
    let hear     = Hear.shared
    
    var touchDial  : TouchDial!
    var scene      : Scene!
    var touchForce : TouchDialForce!
    
    var panel       = UIView() // contains dial, crowns, fader
    var phoneCrown  : PhoneCrown!
    
    var skView: SKView!

    let dialSize = CGSize(width: 172, height: 172)

    private var panelFrame = CGRect.zero
    private var touchFrame = CGRect.zero
    private var skViewFrame = CGRect.zero
    private var crownLeftFrame = CGRect.zero
    private var crownRightFrame = CGRect.zero

    private var observer: NSKeyValueObservation?

    func makeFrames() {

        let viewY = CGFloat(8)
        let viewW = self.view.frame.size.width
        let viewH = self.view.frame.size.height - viewY
        let dialW = dialSize.width
        let dialH = dialSize.height
        let margin = CGFloat(16)
        let panelY = viewH - dialH - margin // start of touch panel
        let crownW = (viewW - dialW)/2
        let xR = viewW - crownW

        panelFrame = CGRect(x:0, y:panelY, width: viewW, height: dialH + margin)
        touchFrame = CGRect(x:0,y:0, width:dialW, height:dialH)
        skViewFrame = CGRect(x:crownW, y:0, width: dialW, height: dialH)
        crownLeftFrame  = CGRect(x: 0,  y:0, width:crownW, height: dialH)
        crownRightFrame = CGRect(x: xR, y:0, width:crownW, height: dialH)
        pagesVC.panelY = panelY
        view.frame.origin.y = viewY
    }

    func updateFrames() {
        makeFrames()
        touchForce.frame = touchFrame
        panel.frame = panelFrame
        skView.frame = skViewFrame
        phoneCrown.frame = crownLeftFrame
        phoneCrown.twin.frame = crownRightFrame
    }


    override func viewDidLoad() {
        
        super.viewDidLoad()

        printLog("◰ \(type(of: self)) \(view.bounds) ")
        observer = view.layer.observe(\.bounds) { object, _ in
            print(object.bounds)
        }

        // stay dark in invert mode
        view.accessibilityIgnoresInvertColors = true

        // Muse.shared.testScript() // for future use of ParGraph

        makeFrames()


        view.addSubview(pagesVC.view)
        
        panel.frame = panelFrame
        scene = Scene(size: dialSize)
        
        view.backgroundColor = .black
        panel.backgroundColor = .black
        
        // dial scene
        
        anim.table = pagesVC.eventTable
        touchDial = TouchDial(dialSize, pagesVC.eventTable)
        touchForce = TouchDialForce(frame: touchFrame)
        touchForce.touchDial = touchDial
        
        skView = SKView(frame:skViewFrame)
        skView.backgroundColor = UIColor.black
        skView.presentScene(scene)
        skView.preferredFramesPerSecond = 60
        skView.addSubview(touchForce)

        // delegates
        
        actions.scene = scene
        active.scene = scene
        pagesVC.eventTable?.scene = scene
        pagesVC.view.backgroundColor = .clear

        actions.tableDelegate = pagesVC.eventTable
        session.startSession()

        // crown left right

        phoneCrown = PhoneCrown(left:crownLeftFrame, right:crownRightFrame, pagesVC.eventTable)
        
        // view hierarcy

        view.addSubview(panel)
        panel.addSubview(skView)
        panel.addSubview(phoneCrown)
        panel.addSubview(phoneCrown.twin)
    }
 
    func setBorder(_ v:UIView) {
        v.layer.cornerRadius = 16
        v.layer.borderColor = headColor.cgColor
        v.layer.borderWidth = 1
        v.layer.masksToBounds = true
    }

    override func viewDidAppear(_ animated: Bool) { printLog("⟳ \(#function)")
        active.startActive()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        observer?.invalidate()
        //...
    }

    override func prefersHomeIndicatorAutoHidden() -> Bool {
        return true
    }

    override var prefersStatusBarHidden : Bool {
        return false
    }
        
  }

