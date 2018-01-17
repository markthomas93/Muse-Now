
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
    static let tourOnboard  = TourSet(rawValue: 1 << 0) // 1
    static let tourMain     = TourSet(rawValue: 1 << 1) // 2
    static let tourMenu     = TourSet(rawValue: 1 << 2) // 4
    static let information  = TourSet(rawValue: 1 << 3) // 8
    static let construction = TourSet(rawValue: 1 << 4) // 16
    static let purchase     = TourSet(rawValue: 1 << 5) // 32
    static let size = 6
}

class BubbleTour {

    static var shared = BubbleTour()
    var sections = [BubbleSection]()    // an array of sections, each may be part of tour or attached toTreeCell
    var tourBubbles = [Bubble]()        // array of bubbles for tour
    var sectionNow: BubbleSection!
    var bubbleNow: Bubble!              // current bubble showing for this tour
    var touring = false                 // wait for one tour to finsh before beginning a new one
    var tourSet = TourSet([.tourOnboard,.tourMain,.tourMenu])
    var mainView: UIView! // full screen view in which to place subview

    /**
     first time tour
     */
    func beginTourSet(_ tourSet_:TourSet) {
        tourSet = tourSet_
        //if tourSet.contains([.tourMain]) { buildMainTour() }
        if tourSet.contains([.tourMenu]) { buildMenuTour() }

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


    func doTourAction(_ act:DoAction) {

        switch act {
        case .tourAll:      beginTourSet([.tourMain,.tourMenu])    ; Haptic.play(.start)
        case .tourMain:     beginTourSet([.tourMain])    ; Haptic.play(.start)
        case .tourMenu:     beginTourSet([.tourMenu])    ; Haptic.play(.start)
        case .tourOnboard:  beginTourSet([.tourOnboard]) ; Haptic.play(.start)
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
    func cancelSection(_ section:BubbleSection) {
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
    func tourSection(_ section:BubbleSection,_ done: @escaping CallBool) {
        if BubblesPlaying.shared.playing {
            BubblesPlaying.shared.cancelBubbles()
        }
        sectionNow = section
        tourBubbles(section.bubbles,done)
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
