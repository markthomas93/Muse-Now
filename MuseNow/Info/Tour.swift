
import Foundation
import UIKit

enum BubContent { case  text, picture, video }

extension UIWindow {
    open override func motionEnded(_ motion: UIEventSubtype, with event: UIEvent?) {
        super.motionEnded(motion, with: event)
        if motion == .motionShake {
            Actions.shared.doAction(.stopTour)
        }
    }
}

struct TourSet: OptionSet {
    let rawValue: Int
    static let onboard  = TourSet(rawValue: 1 << 0) // 1
    static let main     = TourSet(rawValue: 1 << 1) // 2
    static let menu     = TourSet(rawValue: 1 << 2) // 4
    static let information  = TourSet(rawValue: 1 << 3) // 8
    static let construction = TourSet(rawValue: 1 << 4) // 16
    static let purchase     = TourSet(rawValue: 1 << 5) // 32
    static let size = 6
}

class Tour {

    static var shared = Tour()
    var sections = [TourSection]()    // an array of sections, each may be part of tour or attached toTreeCell
    var tourBubbles = [Bubble]()        // array of bubbles for tour
    var sectionNow: TourSection!
    var bubbleNow: Bubble!              // current bubble showing for this tour
    var touring = false                 // wait for one tour to finsh before beginning a new one
    var tourSet = TourSet([.onboard,.main,.menu])
    var mainView: UIView! // full screen view in which to place subview

    /**
     first time tour
     */
    func beginTourSet(_ tourSet_:TourSet) {

        tourSet = tourSet_

        if tourSet.contains([.main]) { buildMainTour() }
        if tourSet.contains([.menu]) { buildMenuTour() }

        attachInfoSections()

        Actions.shared.doAction(.gotoFuture)
        tourBubbles(tourBubbles) { _ in
            self.stopTour()
        }
    }

    func stopTour() {
        BubblesPlaying.shared.cancelBubbles()
        tourSet = []
        // clear out memory?
        for bubble in tourBubbles {
            bubble.prevBubble = nil
        }
        tourBubbles.removeAll()
        TouchScreen.shared.endRedirecting()
    }

    // parse content list ------------------------------------


    func bubsFrom(_ anys:[Any]) -> [BubbleItem] {

        var bubItems = [BubbleItem]()
        var bubItem: BubbleItem!

        func makeItem(_ str:String,_ dur: TimeInterval,_ call:CallWait!) {
            bubItem = BubbleItem(str,dur,call)
            bubItems.append(bubItem)
        }

        for any in anys {
            switch any {
            case let any as String:     makeItem(any,2.0,nil)
            case let any as Int:        bubItem?.duration = TimeInterval(any) // modify last item
            case let any as Double:     bubItem?.duration = TimeInterval(any) // modify last item
            case let any as Float:      bubItem?.duration = TimeInterval(any) // modify last item
            case let any as CallWait:   makeItem("CallWait",0.5,any)
            case let any as CallVoid:   makeItem("CallWait",0.5,{ _, finish in any() ; finish() })
            default: continue
            }
        }
        return bubItems
    }

    func doTourAction(_ act:DoAction) {

        switch act {
        case .tourAll:      beginTourSet([.main,.menu])    ; Haptic.play(.start)
        case .main:     beginTourSet([.main])    ; Haptic.play(.start)
        case .menu:     beginTourSet([.menu])    ; Haptic.play(.start)
        case .onboard:  beginTourSet([.onboard]) ; Haptic.play(.start)
        case .stopTour:     stopTour()                   ; Haptic.play(.stop)
        default: break
        }
    }

    func attachInfoSections() {
        if let root = TreeNodes.shared.root {
            for section in sections {
                if !section.tourSet.intersection([.information,.purchase,.construction]).isEmpty {
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
    func tourSection(_ section:TourSection,_ done: @escaping CallBool)  {
        if BubblesPlaying.shared.playing {
           BubblesPlaying.shared.cancelBubbles()
        }
        sectionNow = section
       tourBubbles(section.bubbles, done)
    }
    /**
     tour a chain of bubbles. Block multiple tours from occuring at same time
     */
    func tourBubbles(_ bubbles:[Bubble],_ done: @escaping CallBool) {

        if BubblesPlaying.shared.playing {
            return done(false)
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
            done(true)
        }
    }

}