
import Foundation
import UIKit
import SpriteKit

enum BubContent { case  text, picture, video }

extension UIWindow {
    open override func motionEnded(_ motion: UIEventSubtype, with event: UIEvent?) {
        super.motionEnded(motion, with: event)
        if motion == .motionShake {
            Actions.shared.doAction(.tourStop)
        }
    }
}

struct TourSet: OptionSet {
    let rawValue: Int
    static let intro    = TourSet(rawValue: 1 << 0) // 1
    static let main     = TourSet(rawValue: 1 << 1) // 2
    static let menu     = TourSet(rawValue: 1 << 2) // 4
    static let info     = TourSet(rawValue: 1 << 3) // 8
    static let detail   = TourSet(rawValue: 1 << 4) // 16
    static let buy      = TourSet(rawValue: 1 << 5) // 32
    static let beta     = TourSet(rawValue: 1 << 6) // 64
    static let size = 6
}

class Tour {

    static var shared = Tour()

    //var sections = [TourSection]()      // an array of sections, each may be part of tour or attached toTreeCell
    var tourBubbles = [Bubble]()        // array of bubbles for tour
    var sectionNow: TourSection!
    var bubbleNow: Bubble!              // current bubble showing for this tour
    var touring = false                 // wait for one tour to finsh before beginning a new one
    var tourSet = TourSet([.intro,.main,.menu])

    var mainVC: MainVC!
    var mainView: UIView! // full screen view in which to place subview

    var eventView :UITableView!

    var pagesVC: PagesVC!
    var pageView: UIView!

    var treeVC: TreeTableVC!
    var treeView: UIView!
    var treeRoot: TreeNode!

    var panelView: UIView!
    var dialView: SKView!
    var crownLeft: PhoneCrown!
    var crownRight: PhoneCrown!

    var isSpeakerOn = true
    let textSize  = CGSize(width:248,height:64)
    let videoSize = CGSize(width:248,height:248)
    let textDelay = TimeInterval(3)

    func initTour() {

        if mainVC != nil { return }

        mainVC = MainVC.shared!
        mainView = mainVC.view!
        pagesVC = PagesVC.shared
        pageView = pagesVC.view!

        eventView = pagesVC.eventVC.tableView!

        treeVC = pagesVC.treeVC!
        treeView = treeVC.view!

        TreeNodes.shared.initTree(treeVC)
        treeRoot = TreeNodes.shared.root!

        panelView = MainVC.shared!.panel
        mainVC = MainVC.shared!
        dialView = mainVC.skView
        crownLeft = mainVC.phoneCrown!
        crownRight = crownLeft.twin!
    }

    // callbacks

    let nextEvent   = { PhoneCrown.shared.delegate.phoneCrownDeltaRow(1,true) }
    let toggleEvent = { PhoneCrown.shared.delegate.phoneCrownToggle(true) }
    let scanEvents  = { Anim.shared.scanFuture() }

    /// goto menu page
    let gotoMenuPage: CallWait! = { finish  in
        PagesVC.shared.gotoPageType(.menu) {
            Actions.shared.doAction(.gotoFuture)
            finish()
        }
    }

    /// goto main page
    let gotoMainPage: CallWait! = { finish in
        PagesVC.shared.gotoPageType(.main) {
            if let treeNode = TreeNodes.shared.root?.find(title:"routine")?.treeNode {
                treeNode.set(isOn: true)
                Actions.shared.doAction(.gotoFuture)
                finish()
            }
            else {
                Actions.shared.doAction(.gotoFuture)
                finish()
            }
        }
    }

    /// Build info section
    func buildInfoSet() {

        initTour()
        var sections = [TourSection]()
        buildMenuTour(.info,&sections)
        attachInfoSections(&sections)
    }

    /// full tour
    func beginTourSet(_ tourSet_:TourSet) {

        tourSet = tourSet_
        initTour()
        var sections = [TourSection]()
        tourBubbles = [Bubble]()
        if tourSet.contains([.main])   { buildMainTour(&sections) }
        if tourSet.contains([.menu])   { buildMenuTour(.menu,&sections) }
        if tourSet.contains([.detail]) { buildMenuTour(.detail,&sections) }

        Actions.shared.doAction(.gotoFuture)
        Settings.shared.prepareDemoSettings()
        tourBubbles(tourBubbles) {
            self.stopTour()
            Settings.shared.finishDemoSettings()
        }
    }

    func stopTour() {
        BubblesPlaying.shared.cancelBubbles()
        // clear out memory?
        for bubble in tourBubbles {
            bubble.prevBubble = nil
        }
        tourBubbles.removeAll()
        TouchScreen.shared.endRedirecting()
        Settings.shared.finishDemoSettings()
    }

    // parse content list ------------------------------------

    func bubsFrom(_ anys:[Any]) -> [BubbleItem] {

        var bubItems = [BubbleItem]()
        var bubItem: BubbleItem!

        func makeItem(_ str:String,_ dur: TimeInterval,_ call:CallWait!) {
            if str.contains(".aif") {
                bubItem?.audioFile = str
            }
            else  {
                bubItem = BubbleItem(str,dur,call)
                bubItems.append(bubItem)
            }
        }

        for any in anys {
            switch any {
            case let any as String:     makeItem(any,2.0,nil)
            case let any as Int:        bubItem?.duration = TimeInterval(any) // modify last item
            case let any as Double:     bubItem?.duration = TimeInterval(any) // modify last item
            case let any as Float:      bubItem?.duration = TimeInterval(any) // modify last item
            case let any as CallWait:   makeItem("CallWait", 0.5, any)
            case let any as CallVoid:   makeItem("CallWait", 0.5, { finish in any() ; finish() })
            default: continue
            }
        }
        return bubItems
    }

    func doTourAction(_ act:DoAction) {

        switch act {
        case .tourAll:    beginTourSet([.main,.menu])
        case .tourMain:   beginTourSet([.main])
        case .tourMenu:   beginTourSet([.menu])
        case .tourDetail: beginTourSet([.detail])
        case .tourIntro:  beginTourSet([.intro])
        case .tourStop:   stopTour() ; Haptic.play(.stop) ; return
        default: return
        }
        Haptic.play(.start)
    }

    func attachInfoSections(_ sections: inout [TourSection]) {
        if let root = TreeNodes.shared.root {
            for section in sections {
                if !section.tourSet.intersection([.info,.buy,.beta]).isEmpty {
                    if let cell = root.find(title:section.title) {
                        cell.addInfoBubble(section)
                    }
                }
            }
        }
    }

    /**
     Called from TreeCell, when user navigated away.
     So cancel from currently playing cell
     */
    func cancelSection(_ section:TourSection) {
        if sectionNow?.title == section.title {
            if BubblesPlaying.shared.playing {
                BubblesPlaying.shared.cancelBubbles()
            }
            sectionNow = nil
        }
    }
    /**
     Called from TreeCell, when user tapped on info
     */
    func tourSection(_ section:TourSection,_ done: @escaping CallVoid)  {
        if BubblesPlaying.shared.playing {
           BubblesPlaying.shared.cancelBubbles()
        }
        sectionNow = section
       tourBubbles(section.bubbles, done)
    }
    /**
     tour a chain of bubbles. Block multiple tours from occuring at same time
     */
    func tourBubbles(_ bubbles:[Bubble],_ done: @escaping CallVoid) {

        if BubblesPlaying.shared.playing {
           BubblesPlaying.shared.cancelBubbles()
        }
        BubblesPlaying.shared.playing = true
        
        // build linked list
        var prevBubble: Bubble! = nil
        for bubble in bubbles {
            prevBubble?.nextBubble = bubble
            bubble.prevBubble = prevBubble
            prevBubble = bubble
        }
        // trim first and last from previous tour
        bubbles.first?.prevBubble = nil
        bubbles.last?.nextBubble = nil

        // begin tour
        bubbles.first?.tourNextBubble() {
            BubblesPlaying.shared.playing = false
            self.touring = false //?? why are there two states?
            self.sectionNow = nil
            done()
        }
    }

}
