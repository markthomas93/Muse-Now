import WatchKit

class WatchCon: WKInterfaceController {
    static var shared: WatchCon!
    let actions  = Actions.shared
    let active   = Active.shared
    let memos    = Memos.shared
    let marks    = Marks.shared
    let anim     = Anim.shared
    let crown    = Crown.shared
    let dots     = Dots.shared
    let hear     = Hear.shared

    var scene: Scene!
    var touchDial: TouchDial!
    var colorSlider: TouchMove!
    
    var size = CGSize(width:0, height:0)
    
    // storyboard

    @IBOutlet var skInterface : WKInterfaceSKScene!

    // life cycle  -------------------------------------

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

    override func didAppear() { Log("⟳ \(#function)")
    }

    override func willDisappear() { Log("⟳ \(#function)")
    }

    override func didDeactivate() { //Log("⟳ \(#function))")
        active.stopActive()
    }


    /// - via: WatchCon.awake
    func initScene() {

        if scene == nil {

            let w = roundf(Float(self.contentFrame.size.width  / 4)) * 8

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
            colorSlider = TouchMove(size)
        }
        Session.shared.startSession()
    }

    // Pan  -------------------------------------

    @IBAction func panAction(_ sender: Any) {

        if let pan = sender as? WKPanGestureRecognizer {

            let pos1 = pan.locationInObject()
            let pos2 = CGPoint(x:pos1.x*2, y:pos1.y*2 )

            let timestamp = Date().timeIntervalSince1970
            switch pan.state {
            case .began:     touchDial.began(pos2, timestamp)
            case .changed:   touchDial.moved(pos2, timestamp)
            case .ended:     touchDial.ended(pos2, timestamp)
            case .cancelled: touchDial.ended(pos2, timestamp)
            default: break
            }
        }
    }

    @IBAction func sliderAction(_ sender: Any) {

        #if false
        if let pan = sender as? WKPanGestureRecognizer {

            let pos1 = pan.locationInObject()
            let pos2 = CGPoint(x:pos1.x*2, y:pos1.y*2 )

            let timestamp = Date().timeIntervalSince1970
            switch pan.state {
            case .began:     colorSlider.began(pos2, timestamp)
            case .changed:   colorSlider.moved(pos2, timestamp)
            case .ended:     colorSlider.ended(pos2, timestamp)
            case .cancelled: colorSlider.ended(pos2, timestamp)
            default: break
            }
        }
        #endif
    }


    // menu actions  -------------------------------------
    
    @IBAction func menuMarkAction() { Log("✓ \(#function)")
        active.startMenuTime()
        actions.markAction(.markOn, /*event*/ nil, anim.getIndexForMark(), /*isSender*/ true)
    }
    
    @IBAction func menuClearAction() { Log("✓ \(#function)")
        active.startMenuTime()
        actions.markAction(.markOff, /*event*/ nil, anim.getIndexForMark(), /*isSender*/ true)
    }
    
    @IBAction func menuMenuAction() { Log("⿳ \(#function)")
        active.startMenuTime()
        TreeNodes.shared.initTree(self)
        WatchMenu.shared.menu()
    }

    @IBAction func tap1Action(_ sender: Any) { Log("👆\(#function)")

        let timeStamp = Date().timeIntervalSinceReferenceDate
        Taps.shared.tapping(timeStamp)
    }

}
