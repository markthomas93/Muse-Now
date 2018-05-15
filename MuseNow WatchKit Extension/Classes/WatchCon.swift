import WatchKit

class WatchCon: WKInterfaceController {

    static var shared: WatchCon!
    let actions = Actions.shared
    let active  = Active.shared
    let memos   = Memos.shared
    let marks   = Marks.shared
    let anim    = Anim.shared
    let crown   = Crown.shared
    let dots    = Dots.shared
    let hear    = Hear.shared

    var scene: Scene!
    var touchDial: TouchDial!
    var touchSlider: TouchMove!
    var tourSet: TourSet = [.main]
    
    var size = CGSize(width:0, height:0)
     
    @IBOutlet var skInterface : WKInterfaceSKScene!

    override func awake(withContext context: Any?) { Log("⟳ \(#function) context:\(context ?? "nil")")
        //Muse.shared.testScript()
        WKExtension.shared().isFrontmostTimeoutExtended = true
        initScene()
        crown.updateCrown()
        let nextMinute = MuDate.relativeMinute(1)
        WKExtension.shared().scheduleBackgroundRefresh(withPreferredDate: nextMinute, userInfo:nil, scheduledCompletion: {_ in})
    }
    
    override func willActivate() { //Log("⟳ \(#function)")
        
        active.startActive()
        crown.crown.focus()
    }
    override func didDeactivate() { // Log("⟳ \(#function))")
        active.stopActive()
    }

    /// - via: WatchCon.awake
    func initScene() {

        if scene == nil {

            let w = self.contentFrame.size.width * 2

            size = CGSize(width:CGFloat(w), height:CGFloat(w))

            scene = Scene(size : size)

            Log("⟳ \(#function) id:\(scene.id)")
            skInterface.preferredFramesPerSecond = 60
            skInterface.setAlpha(0) // kludge to overcome white flash on apple watch
            skInterface.presentScene(scene)

            //??? scene.isPaused = true
            WatchCon.shared = self
            actions.scene = scene
            active.scene = scene
            anim.scene = scene

            touchDial = TouchDial(size, nil)

            touchDial.swipeRightAction = { _ in Log("👆 touchSwipeRight")
                self.pushMenu()
            }
            touchDial.swipeLeftAction = { _ in Log("👆 touchSwipeLeft")
            }

            touchSlider = TouchMove(size)
        }
        Session.shared.startSession()
    }

    func pushMenu() {
        tourSet = [.menu]
        anim.gotoStartupAnim()
        active.startMenuTime()
        TreeNodes.shared.initTree(self)
        WatchMenu.shared.showMenu()
    }

  }
