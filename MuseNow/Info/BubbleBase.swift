//
//  BubbleBase.swift
//  MuseNow
//
//  Created by warren on 12/17/17.
//  Copyright © 2017 Muse. All rights reserved.
//

import Foundation
import UIKit

class BubbleBase: MuDrawBubble {

    var outFrame = CGRect.zero      // popOut frame
    var contentFrame = CGRect.zero
    let marginW = CGFloat(8)        // margin inside bezel
    let innerH = CGFloat(36)        // inner height / 4 determines cell bezel radius

    var poi: TourPoi!
    var family = [UIView]()         // grand, parent, child views
    var covers = [UIView]()         // views in which to darken while showing bubble
    var duration = TimeInterval(60) // seconds to show bubble
    var options = TourOptions([])

    var done: ((Bool)->())?         // callback after tucking in bubble
    var timer = Timer()             // timer for duration between popOut and tuckIn

    var blankChild: UIView!         // optional bezel from which to spring bubble
    let coverAlpha = CGFloat(0.70)  // alpha for covers which darken background
    var deltaX = CGFloat(0)

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    /**
     Create a bubble with text with timeout and completion callback

     - Parameter str: text to display inside bubble
     - Parameter family_: family of view grand, parent, child
     - Parameter covering_: list of views to cover with darking alpha views
     - Parameter duration_: duration of pop-out
     - Parameter completion_: completion callback

     - family[0]: grand of parent view. Will bring parent to front.
     - family[1]: parent if child view. Stays uncovered; others darken.
     - family[2]: child view to spring bubble from. Will not clip.

     - note: if no family[2], then will create a blankChild
     */

    init(_ poi_:TourPoi) {

        poi = poi_
        family = poi.family
        duration = poi.duration
        options = poi.options


        let radius = CGFloat(16)
        let size = poi.size

        if family.count < 3 {
            var blankFrame = family[1].frame
            blankFrame.origin = .zero
            blankChild = UIView(frame:blankFrame)
            blankChild.backgroundColor = .clear
            if options.contains(.highlight) {
                blankChild.layer.borderColor = UIColor.white.cgColor
                blankChild.layer.borderWidth = 1
                if options.contains(.circular) {
                    blankChild.layer.cornerRadius = min(blankFrame.width,blankFrame.height)/2
                }
                else {
                    blankChild.layer.cornerRadius = innerH / 4 // same as cell corner radius
                }
            }
            blankChild.isUserInteractionEnabled = false
            family[1].addSubview(blankChild)
            family.append(blankChild)
        }

        super.init(poi.bubType, size, radius, family) // create bubbleFrame
        self.isUserInteractionEnabled = true

        for underView in poi.covers {

            let cover = UIView(frame:underView.frame)
            cover.frame.origin = .zero
            cover.backgroundColor = .black
            cover.alpha = 0.0
            cover.isUserInteractionEnabled = false

            covers.append(cover)
            underView.addSubview(cover)
        }

        outFrame = family[1].convert(self.frame,      from: family[0])

//        let inFrame000 = family[0].convert(family[0].frame, from: family[0])
//        let inFrame001 = family[0].convert(family[0].frame, from: family[1])
//        let inFrame002 = family[0].convert(family[0].frame, from: family[2])
//        let inFrame010 = family[0].convert(family[1].frame, from: family[0])
//        let inFrame011 = family[0].convert(family[1].frame, from: family[1])
//        let inFrame012 = family[0].convert(family[1].frame, from: family[2])
//        let inFrame020 = family[0].convert(family[2].frame, from: family[0])
//        let inFrame021 = family[0].convert(family[2].frame, from: family[1])
//        let inFrame022 = family[0].convert(family[2].frame, from: family[2])
//        let inFrame100 = family[1].convert(family[0].frame, from: family[0])
//        let inFrame101 = family[1].convert(family[0].frame, from: family[1])
//        let inFrame102 = family[1].convert(family[0].frame, from: family[2])
//        let inFrame110 = family[1].convert(family[1].frame, from: family[0])
//        let inFrame111 = family[1].convert(family[1].frame, from: family[1])
//        let inFrame112 = family[1].convert(family[1].frame, from: family[2])
//        let inFrame120 = family[1].convert(family[2].frame, from: family[0])
//        let inFrame121 = family[1].convert(family[2].frame, from: family[1])
//        let inFrame122 = family[1].convert(family[2].frame, from: family[2])
//        let inFrame200 = family[2].convert(family[0].frame, from: family[0])
//        let inFrame201 = family[2].convert(family[0].frame, from: family[1])
//        let inFrame202 = family[2].convert(family[0].frame, from: family[2])
//        let inFrame210 = family[2].convert(family[1].frame, from: family[0])
//        let inFrame211 = family[2].convert(family[1].frame, from: family[1])
//        let inFrame212 = family[2].convert(family[1].frame, from: family[2])
//        let inFrame220 = family[2].convert(family[2].frame, from: family[0])
//        let inFrame221 = family[2].convert(family[2].frame, from: family[1])
//        let inFrame222 = family[2].convert(family[2].frame, from: family[2])
//
//        print("self:(\(self.frame.midX), \(self.frame.midY))")
//        print("outC:(\(outFrame.midX), \(outFrame.midY))")
//
//        print("in000:(\(inFrame000.midX), \(inFrame000.midY))")
//        print("in001:(\(inFrame001.midX), \(inFrame001.midY))")
//        print("in002:(\(inFrame002.midX), \(inFrame002.midY))")
//        print("in010:(\(inFrame010.midX), \(inFrame010.midY))")
//        print("in011:(\(inFrame011.midX), \(inFrame011.midY))")
//        print("in012:(\(inFrame012.midX), \(inFrame012.midY))")
//        print("in020:(\(inFrame020.midX), \(inFrame020.midY))")
//        print("in021:(\(inFrame021.midX), \(inFrame021.midY))")
//        print("in022:(\(inFrame022.midX), \(inFrame022.midY))\n")
//
//        print("in100:(\(inFrame100.midX), \(inFrame100.midY))")
//        print("in101:(\(inFrame101.midX), \(inFrame101.midY))")
//        print("in102:(\(inFrame102.midX), \(inFrame102.midY))")
//        print("in110:(\(inFrame110.midX), \(inFrame110.midY))")
//        print("in111:(\(inFrame111.midX), \(inFrame111.midY))")
//        print("in112:(\(inFrame112.midX), \(inFrame112.midY))")
//        print("in120:(\(inFrame120.midX), \(inFrame120.midY))")
//        print("in121:(\(inFrame121.midX), \(inFrame121.midY))")
//        print("in122:(\(inFrame122.midX), \(inFrame122.midY))\n")
//
//        print("in200:(\(inFrame200.midX), \(inFrame200.midY))")
//        print("in201:(\(inFrame201.midX), \(inFrame201.midY))")
//        print("in202:(\(inFrame202.midX), \(inFrame202.midY))")
//        print("in210:(\(inFrame210.midX), \(inFrame210.midY))")
//        print("in211:(\(inFrame211.midX), \(inFrame211.midY))")
//        print("in212:(\(inFrame212.midX), \(inFrame212.midY))")
//        print("in220:(\(inFrame220.midX), \(inFrame220.midY))")
//        print("in221:(\(inFrame221.midX), \(inFrame221.midY))")
//        print("in222:(\(inFrame222.midX), \(inFrame222.midY))")
//

        let outFrameX = family[0].convert(outFrame, to: nil).origin.x + self.frame.size.width/2
        let inFrameX  = family[0].convert(family[2].frame, to: nil).origin.x + family[2].frame.size.width/2
        deltaX =  inFrameX - outFrameX

        alpha = 0
        self.frame = outFrame
        family[1].addSubview(self)

        // setup content frame
        let m = marginW
        let m2 = marginW*2
        let r = radius
        let w = bubFrame.size.width - m2
        let h = bubFrame.size.height - m2

        switch poi.bubType {
        case .above:  contentFrame = CGRect(x:m,   y:m+r, width:w, height:h-r)
        case .below:  contentFrame = CGRect(x:m,   y:m,   width:w, height:h-r)
        case .left:   contentFrame = CGRect(x:m+r, y:m,   width:w-r, height:h)
        case .right:  contentFrame = CGRect(x:m,   y:m,   width:w-r, height:h)
        case .center: contentFrame = CGRect(x:m,   y:m,   width:w, height:h)
        }

    }

    
    func go(_ done_: @escaping ((Bool)->())) {
        done = done_
        popOut() {
            self.timer = Timer.scheduledTimer(withTimeInterval: self.duration, repeats: false, block: {_ in
                self.tuckIn(true)
            })
        }
    }
    /**
     Calculate translation to make translation appear to start from top of inFrame.
     Without translation, the scale animation will appear from center.
     So, the translation needs shift the center of x coordinate
     */
    func getTranslation() -> CGPoint {

        let vx = viewPoint.x
        let vy = viewPoint.y
        let vw = poi.family[2].frame.size.width
        let vh = poi.family[2].frame.size.height
        let vmx = vx + vw/2
        let vmy = vy + vh/2

        let ox = outFrame.origin.x
        let oy = outFrame.origin.y
        let ow = outFrame.size.width
        let oh = outFrame.size.height
        let omx = ox + ow/2
        let omy = oy + oh/2

//        let voh = vh/oh
//        let vow = vw/ow
//
//        let ovh = oh/vh
//        let ovw = ow/vw



        print ("\(poi.bubType)\n v:(\(vx),\(vy) \(vw),\(vh) \(vmx),\(vmy))\n o:(\(ox),\(oy) \(ow),\(oh)  \(omx),\(omy))")

        switch poi.bubType {
        case .above:  return CGPoint(x: (vmx-omx)/2, y: -oh/2)
        case .below:  return CGPoint(x: (vmx-omx)/2, y:  oh/2)

        case .left:   return CGPoint(x: -ow/2, y: 0)
        case .right:  return CGPoint(x:  ow/2, y: 0)
        case .center: return .zero
        }
    }
    /**
     Grow animation outward from inFrame to outFrame.
     To insure that bubble appears above other views,
     bring family[1] to front of family[0].
     */
    func popOut(_ popDone:@escaping()->()) {

        if poi.options.contains(.overlay) {
            transform = .identity
            alpha = 0.0
        }
        else {
            family[0].bringSubview(toFront: family[1])

            let scale = CGFloat(0.01)
            let t = getTranslation()
            alpha = 0.5
            self.transform = CGAffineTransform (
                a: scale, b: 0.0,
                c: 0.0,   d: scale,
                tx: t.x,  ty: t.y)
        }
        UIView.animate(withDuration: 1.0, delay: 0.0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: [.curveEaseOut], animations: {
            self.alpha = 1.0
            for cover in self.covers {
                cover.alpha = self.coverAlpha
            }
            self.transform = .identity
        }, completion: { _ in
            popDone()
        })
    }

    /**
     Shrink animation inward from outFrame to inFrame.
     After animation completion, call self's completion
     and remove from superview, which should deinit.
     */
    func tuckIn(_ timeout:Bool) {

        func fadeOut(_ done: @escaping (()->())) {
            UIView.animate(withDuration: 1.0, animations: {
                self.alpha = 0.0
                for cover in self.covers {
                    cover.alpha = 0.0
                }
                self.blankChild?.alpha = 0

            }, completion: { _ in
                done()
            })
        }

        func removeCovers() {
            self.removeFromSuperview()
            for cover in self.covers {
                cover.removeFromSuperview()
            }
            self.blankChild?.removeFromSuperview()
        }

        // begin -----------------------------------

        if poi.nextPoi?.options.contains(.overlay) ?? false {
            done?(false) // start other  bubble in parallel
            fadeOut() {
                removeCovers()
            }

        } else {
            fadeOut() {
                removeCovers()
                self.done?(false)
            }
        }

    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) { //print(#function)
        timer.invalidate()
        self.tuckIn(false)
        //super.touchesBegan(touches, with: event)
    }

}

