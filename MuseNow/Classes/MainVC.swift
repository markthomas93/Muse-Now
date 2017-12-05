
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
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        view.accessibilityIgnoresInvertColors = true
        Muse.shared.testScript()
        let viewY = CGFloat(8)
        let viewW = self.view.frame.size.width
        let viewH = self.view.frame.size.height - viewY
        let dialW = dialSize.width
        let dialH = dialSize.height
        let margin = CGFloat(16)
        let panelY = viewH - dialH - margin // start of touch panel
        let crownW = (viewW - dialW)/2

        pagesVC.panelY = panelY
        view.addSubview(pagesVC.view)
        
        panel.frame = CGRect(x:0, y:panelY, width: viewW, height: dialH + margin)
        scene = Scene(size: dialSize)
        
        self.view.backgroundColor = UIColor.black
        panel.backgroundColor = UIColor.black
        
        // dial scene
        
        anim.table = pagesVC.eventTable
        touchDial = TouchDial(dialSize, pagesVC.eventTable)
        touchForce = TouchDialForce(frame: CGRect(x:0,y:0, width:dialW, height:dialH))
        touchForce.touchDial = touchDial
        
        skView = SKView(frame:CGRect(x:crownW, y:0, width: dialW, height: dialH))
        skView.backgroundColor = UIColor.black
        skView.presentScene(scene)
        skView.preferredFramesPerSecond = 60
        skView.addSubview(touchForce)

        // delegates
        
        actions.scene = scene
        active.scene = scene
        pagesVC.eventTable?.scene = scene
        actions.tableDelegate = pagesVC.eventTable
        session.startSession()

        // crown left right

        let xR = viewW - crownW
        let leftFrame =  CGRect(x: 0,  y:0, width:crownW, height: dialH)
        let rightFrame = CGRect(x: xR, y:0, width:crownW, height: dialH)
        phoneCrown = PhoneCrown(left:leftFrame, right:rightFrame, pagesVC.eventTable)
        
        // view hierarcy
        view.frame.origin.y = viewY
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
    
    override func viewWillDisappear(_ animated: Bool) { printLog("⟳ \(#function)")
        active.stopActive()
    }
    override func prefersHomeIndicatorAutoHidden() -> Bool {
        return true
    }
    override var prefersStatusBarHidden : Bool {
        return false
    }
        
  }

