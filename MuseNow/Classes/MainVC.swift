
import UIKit
import SceneKit
import SpriteKit
import AudioToolbox
import WatchKit

class MainVC: UIViewController {

    static var shared: MainVC?
    let session = Session.shared
    let settings = Settings.shared

    let memos   = Memos.shared
    let marks   = Marks.shared
    let anim    = Anim.shared
    let dots    = Dots.shared
    let pagesVC = PagesVC.shared
    let hear    = Hear.shared

    var active      : Active!
    var actions     : Actions! 
    var onboardVC   : OnboardVC!
    var touchDial   : TouchDial!
    var scene       : Scene!
    var touchForce  : TouchDialForce!
    
    var panel      = UIView() // contains dial, crowns, fader
    var phoneCrown : PhoneCrown!
    
    var skView: SKView!

    let dialSize = CGSize(width: 172, height: 172)

    var pagesFrame = CGRect.zero
    var panelFrame = CGRect.zero
    var touchFrame = CGRect.zero
    var skViewFrame = CGRect.zero
    var crownLeftFrame = CGRect.zero
    var crownRightFrame = CGRect.zero
    var observer: NSKeyValueObservation?

    func updateFrames(_ size:CGSize) {
        
        let height = size.height
        let width  = size.width
        let statusH = UIApplication.shared.statusBarFrame.height

        let isPad = UIDevice.current.userInterfaceIdiom == .pad
        let isPanel = isPad && width < height // is panel inside ipad app
        let isPortrait = height > width // is portrait mode
        let viewY   = CGFloat(isPanel ? 0 : isPad ? 18 : isPortrait ? statusH : 0)
        let viewH   = height - viewY

        let dialW  = dialSize.width
        let dialH  = dialSize.height
        let bottomH = view.safeAreaInsets.bottom
        let panelY = viewH - dialH - bottomH // start of touch panel
        let crownW = (width - dialW)/2
        let crownR = width - crownW
        let pagesH = height - dialH - viewY

        pagesFrame      = CGRect(x: 0,      y:0,      width: width,  height: pagesH)
        panelFrame      = CGRect(x: 0,      y:panelY, width: width,  height: dialH)

        touchFrame      = CGRect(x: 0,      y:0,      width: dialW,  height: dialH)
        skViewFrame     = CGRect(x: crownW, y:0,      width: dialW,  height: dialH)
        crownLeftFrame  = CGRect(x: 0,      y:0,      width: crownW, height: dialH)
        crownRightFrame = CGRect(x: crownR, y:0,      width: crownW, height: dialH)
    }

    func updateViews(_ size:CGSize) {

        updateFrames(size)

        touchForce.frame      = touchFrame
        panel.frame           = panelFrame
        skView.frame          = skViewFrame
        phoneCrown.frame      = crownLeftFrame
        phoneCrown.twin.frame = crownRightFrame

        phoneCrown.initialize()
        phoneCrown.twin.initialize()
        phoneCrown.setNeedsDisplay()
        phoneCrown.twin.setNeedsDisplay()
        pagesVC.updateViews(pagesFrame.size)
    }

    func makeOnboard() {

        if onboardVC == nil {
            onboardVC = OnboardVC()
        }
        onboardVC.view.alpha = 0
        view.addSubview(self.onboardVC.view)

        UIView.animate(withDuration: 1.0, animations: {
            self.onboardVC.view.alpha = 1
        })
    }

    func transitionFromOnboarding() {

        Onboard.shared.state = .completed
        settings.settings["boarding"] = Onboard.shared.state.rawValue
        settings.archiveSettings()
        
        makePages() {
            Actions.shared.doAction(.refresh)
            UIView.animate(withDuration: 1.0, animations: {
                self.onboardVC.view.alpha = 0
            }, completion:{ _ in
                self.onboardVC.view.removeFromSuperview()
                Tour.shared.beginTourSet([.main,.menu])
                Timer.delay(4) {Tour.shared.buildInfoSet()}
            })
        }
    }

    func makePages(_ done: @escaping CallVoid) {

        // some views not yet initialized, so only update frames

        panel.frame = panelFrame
        panel.backgroundColor = .black
        scene = Scene(size: dialSize)

        // dial scene

        anim.table = pagesVC.eventVC
        touchDial  = TouchDial(dialSize, pagesVC.eventVC)
        touchForce = TouchDialForce(frame: touchFrame)
        touchForce.touchDial = touchDial

        skView = SKView(frame:skViewFrame)
        skView.backgroundColor = UIColor.black
        skView.presentScene(scene)
        skView.preferredFramesPerSecond = 60
        skView.addSubview(touchForce)

        // delegates
        actions = Actions.shared
        active = Active.shared
        actions.scene = scene
        active.scene = scene
        pagesVC.eventVC?.scene = scene
        pagesVC.view.backgroundColor = .clear

        actions.tableDelegate = pagesVC.eventVC
        session.startSession()

        // crown left right

        phoneCrown = PhoneCrown(left:crownLeftFrame, right:crownRightFrame, pagesVC.eventVC)

        view.addSubview(panel)
        panel.addSubview(skView)
        panel.addSubview(phoneCrown)
        panel.addSubview(phoneCrown.twin)

        // when screen autorotates or added as a panel on iPad, accomadate resize
        observer = view.layer.observe(\.bounds) { object, _ in
            self.updateViews(object.bounds.size)
            TreeNodes.shared.root.updateViews(object.bounds.size.width)
            Log("▣ observer:\(object.bounds.size)")
        }
        done()
    }

}

