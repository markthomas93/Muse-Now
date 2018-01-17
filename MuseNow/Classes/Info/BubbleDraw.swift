//
//  BubbleDraw.swift
//  MuseNow
//
//  Created by warren on 12/14/17.
//  Copyright © 2017 Muse. All rights reserved.

import Foundation
import UIKit

public enum BubShape { case
    center, above, below, left, right,
    diptych12, diptych22,
    triptych13, triptych23, triptych33
}

class BubbleDraw: UIView {

    var bubFrame = CGRect.zero
    var radius  = CGFloat(16)
    var arrowXY = CGPoint.zero
    var bubble: Bubble! // base view which may contain from in its hierarchy

    // 4 corner control points

    private var ul  = CGPoint.zero  // upper left
    private var ur  = CGPoint.zero  // upper right
    private var bl  = CGPoint.zero  // below left
    private var br  = CGPoint.zero  // below right

    // 8 line segment start end

    private var uls = CGPoint.zero // upper left start
    private var ule = CGPoint.zero // upper left end
    private var urs = CGPoint.zero // upper right start
    private var ure = CGPoint.zero // upper right end
    private var brs = CGPoint.zero // bottom left start
    private var bre = CGPoint.zero // bottom left end
    private var bls = CGPoint.zero // bottom right start
    private var ble = CGPoint.zero // bottom right end

    private var fromX = CGFloat(0) // family[2].frame.origin.x
    private var fromY = CGFloat(0) // family[2].frame.origin.y
    private var fromW = CGFloat(0) // family[2].frame.size.width
    private var fromH = CGFloat(0) // amily[2].frame.size.height

    public var viewPoint = CGPoint.zero // used for animation

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override init(frame:CGRect) {
        super.init(frame: frame)
        self.layer.borderWidth = 1
    }

    override open func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
    }
    override open func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
    }
    override open func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
    }
    override open func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
    }

    /**
     Create a dotted border that may include
     an arrow pointing to from view
    */
    func makeBorder() {

        let from = bubble.from!
        fromX = from.frame.origin.x
        fromY = from.frame.origin.y
        fromW = from.frame.size.width
        fromH = from.frame.size.height

        let size = bubble.size
        switch bubble.bubShape {
        case .above:  makeAbove(size)
        case .below:  makeBelow(size)
        case .left:   makeLeft(size)
        case .right:  makeRight(size)
        default:      makeCenter(size)
        }

        self.frame = bubFrame
    }

    /**
     Shift frame to fit in screen
     - parameter delta: delta point to add to  viewPoint
     - parameter bubSize: size of bubble
     - returns: ViewPoint from which to spring bubble
     */

    func makeBubFrame(_ delta: CGPoint,
                      _ bubSize: CGSize) {

        let fo = bubble.base.convert(bubble.base.frame.origin, from: bubble.from) // from origin

        let x = viewPoint.x + delta.x
        let y = viewPoint.y + delta.y
        let w = bubSize.width
        let h = bubSize.height
        let fow = fo.x + w // frame origin width
        let foh = fo.y + h // from origin height

        let bounds = bubble.base.bounds
        let bW = bounds.size.width
        let bH = bounds.size.height

        bubFrame = CGRect(x: x + fow < bW ? x : bW-fow,
                          y: y + foh < bH ? y : bH-foh,
                          width:w, height:h)

        Log("✏︎💬 makeBubFrame delta:\(delta) fo:\(fo) xywh:(\(x),\(y)),(\(w),\(h)) bwh:\(bW),\(bH) bubFrame:\(bubFrame.origin),\(bubFrame.size)")

        return
    }

    func makeRight(_ size: CGSize) {

        viewPoint = CGPoint(x: 0, y: fromH / 2)

        let delta = CGPoint(x: -size.width - radius,
                            y: -size.height / 2)

        let bubSize = CGSize(width: size.width +  radius,
                             height:size.height)

        makeBubFrame(delta, bubSize)

        arrowXY = CGPoint(x: viewPoint.x - bubFrame.origin.x,
                          y: viewPoint.y - bubFrame.origin.y)

        //Log("💬 makeLeft viewPoint:\(viewPoint) delta:\(delta) bubFrame:\(bubFrame) arrowXY:\(arrowXY)")

    }

    func makeLeft(_ size: CGSize) {

        viewPoint = CGPoint(x: fromW,  y: fromH / 2)
        let delta = CGPoint(x: radius, y: -size.height / 2)

        let bubSize = CGSize(width:  size.width + radius,
                             height: size.height)

        makeBubFrame(delta, bubSize)

        arrowXY = CGPoint(x: 0,
                          y: viewPoint.y - bubFrame.origin.y)

         //Log("💬 makeRight viewPoint:\(viewPoint) delta:\(delta) bubFrame:\(bubFrame) arrowXY:\(arrowXY)")
    }

    func makeBelow(_ size: CGSize) {

        viewPoint = CGPoint(x: fromW/2, y: fromH)
        let delta = CGPoint(x: -size.width/2, y: 0)

        let bubSize = CGSize(width:  size.width,
                             height: size.height + radius)

        makeBubFrame(delta, bubSize)

        arrowXY = CGPoint(x: viewPoint.x - bubFrame.origin.x,
                          y: 0)
         //Log("💬 makeBelow viewPoint:\(viewPoint) delta:\(delta) bubFrame:\(bubFrame) arrowXY:\(arrowXY)")
    }

    func makeAbove(_ size: CGSize) {

        viewPoint = CGPoint(x: fromW/2, y: 0)

        let delta = CGPoint(x: -size.width / 2,
                            y: -size.height - radius)

        let bubSize = CGSize(width:  size.width,
                             height: size.height + radius)

        makeBubFrame(delta, bubSize)

        arrowXY = CGPoint(x: viewPoint.x - bubFrame.origin.x,
                          y: viewPoint.y - bubFrame.origin.y)

          Log("💬 makeAbove viewPoint:\(viewPoint) delta:\(delta) bubFrame:\(bubFrame) arrowXY:\(arrowXY)")
    }


    func makeCenter(_ size: CGSize) {

        let subM = CGFloat(4) // sub margin

        func makeFrame(_ position:CGFloat, _ count: CGFloat) {
            

            let subW = (fromW - (count-1)*subM) / count
            let subH = size.width/size.height * subW
            let x = (position-1) * (subW + subM)
            let y = max(0,(fromH-subH)/2)
            
            viewPoint = CGPoint(x: x+subW/2, y: y+subH/2)
            let delta = bubble.options.contains(.snugAbove)
                ? CGPoint(x: -subW/2, y: -subH - subM)
                : CGPoint(x: -subW/2, y: -subH/2)

            let bubSize = CGSize(width:  subW, height: subH)
            
            makeBubFrame(delta, bubSize)
             //Log("💬 make.\(bubShape) viewPoint:\(viewPoint) delta:\(delta) bubFrame:\(bubFrame) arrowXY:\(arrowXY)")
        }
        switch bubble.bubShape {
        case .diptych12:  makeFrame(1,2)
        case .diptych22:  makeFrame(2,2)
        case .triptych13: makeFrame(1,3)
        case .triptych23: makeFrame(2,3)
        case .triptych33: makeFrame(3,3)

        default:

            viewPoint = CGPoint(x: fromW/2, y: fromH/2)
            let delta = bubble.options.contains(.snugAbove)
                ? CGPoint(x: -size.width/2, y: -size.height - subM)
                : CGPoint(x: -size.width/2, y: -size.height/2)
            let bubSize = size

            makeBubFrame(delta, bubSize)
            //Log("💬 makeCenter viewPoint:\(viewPoint) delta:\(delta) bubFrame:\(bubFrame) arrowXY:\(arrowXY)")
        }

    }

    // paths ---------------------------------------------------------

    func abovePath(_ path:UIBezierPath) {

        let a = arrowXY // arrow point
        let r = radius
        let m = CGFloat(1) // margin

        // end points of arrow
        let am = CGPoint(x: a.x,    y: a.y-r ) // arrow mid point
        var ar = CGPoint(x: am.x+r, y: am.y-m) // arrow right end
        var al = CGPoint(x: am.x-r, y: am.y-m) // arrow left end

        // shorten commands to q_ quad curve, l_ line, s_ scrunch overlapping points
        func q_(_ p:CGPoint,_ c:CGPoint) { path.addQuadCurve(to: p, controlPoint: c) }
        func l_(_ p:CGPoint)             { path.addLine(to: p) }
        func s_(_ p0:inout CGFloat,_ p1:inout CGFloat) { if p0 > p1 { p0 = (p0+p1)/2 ; p1 = p0 } } // middle point of overlap

        s_(&ar.x,&bre.x)                        // scrunch start of arrow if needed
        s_(&bls.x,&al.x)                        // scrunch end of arrow if needed

        path.move(to: a)                        // start of arrow
        q_(al,am) ; if bls.x < al.x { l_(bls) } // end of arrow with optional line
        q_(ble,bl) ; l_(uls)                    // below left corner
        q_(ule,ul) ; l_(urs)                    // upper left corner with line
        q_(ure,ur) ; l_(brs)                    // upper rigth corner with line
        q_(bre,br) ; if ar.x < bre.x { l_(ar) } // below right corner w optional line
        q_(a,am)                                // start of arrow
        path.close()                            // close path with line to upper left
    }



    func belowPath(_ path:UIBezierPath) {

        let a = arrowXY // arrow point
        let r = radius
        let m = CGFloat(1) // margin

        // end points of arrow
        let am = CGPoint(x: a.x,    y: a.y+r ) // arrow mid point
        var ar = CGPoint(x: am.x+r, y: am.y+m) // arrow right end
        var al = CGPoint(x: am.x-r, y: am.y+m) // arrow left end

        // shorten commands to q_ quad curve, l_ line, s_ scrunch overlapping points
        func q_(_ p:CGPoint,_ c:CGPoint) { path.addQuadCurve(to: p, controlPoint: c) }
        func l_(_ p:CGPoint)             { path.addLine(to: p) }
        func s_(_ p0:inout CGFloat,_ p1:inout CGFloat) { if p0 > p1 { p0 = (p0+p1)/2 ; p1 = p0 } } // middle point of overlap

        s_(&ule.x,&al.x)                        // scrunch begin of arrow, if needed
        s_(&ar.x,&urs.x)                        // scrunch end of arrow, if needed

        path.move(to: a)                       // begin arrow
        q_(ar,am) ; if urs.x > ar.x { l_(urs) } // end arrow with optiona line
        q_(ure,ur) ; l_(brs)                    // upper right corner with line
        q_(bre,br) ; l_(bls)                    // below right corner with line
        q_(ble,bl) ; l_(uls)                    // below left corner with line
        q_(ule,ul) ; if ule.x < al.x { l_(al) } // upper left corner w optional line
        q_(a,am)
        path.close()                            // close path w line to upper left
    }

    func rightPath(_ path:UIBezierPath) {

        let a = arrowXY // arrow point
        let r = radius
        let m = CGFloat(1) // margin

        // end points of arrow
        let am = CGPoint(x: a.x-r,   y: a.y   ) // arrow mid point
        var au = CGPoint(x: am.x-m,  y: am.y-r) // arrow upper end
        var ab = CGPoint(x: am.x-m,  y: am.y+r) // arrow below end

        // shorten commands to q_ quad curve, l_ line, s_ scrunch overlapping points
        func q_(_ p:CGPoint,_ c:CGPoint) { path.addQuadCurve(to: p, controlPoint: c) }
        func l_(_ p:CGPoint)             { path.addLine(to: p) }
        func s_(_ p0:inout CGFloat,_ p1:inout CGFloat) { if p0 > p1 { p0 = (p0+p1)/2 ; p1 = p0 } } // middle point of overlap

        s_(&ure.y, &au.y)                       // scrunch begin start of arrow if needed
        s_(&ab.y,&brs.y )                       // sceunch end of arrow if needed

        path.move(to: a)                        // start at tip of arrow
        q_(ab,am) ; if ab.y < brs.y { l_(brs) } // end of arrow w option line to below right
        q_(bre,br) ; l_(bls)                    // below right corner w line
        q_(ble,bl) ; l_(uls)                    // below left corner
        q_(ule,ul) ; l_(urs)                    // upper left start to end
        q_(ure,ur) ; if ure.y < au.y { l_(au) } // upper right corner w optional line to arrow
        q_(a,am)                                // back to beginning of arrow
        path.close()

    }
    func setCorners(U:CGFloat, B:CGFloat, L:CGFloat, R:CGFloat) {

        let r = radius

        // 4 corner control points
        ul  = CGPoint(x: L, y: U) // upper left control point
        ur  = CGPoint(x: R, y: U) // upper right control point
        br  = CGPoint(x: R, y: B) // lower right control point
        bl  = CGPoint(x: L, y: B) // lower left control point

        // 8 line segment start end

        uls = CGPoint(x: L,   y: U+r )  // upper left start
        ule = CGPoint(x: L+r, y: U   )  // upper left end

        urs = CGPoint(x: R-r, y: U   )  // upper right start
        ure = CGPoint(x: R,   y: U+r )  // upper right end

        brs = CGPoint(x: R,   y: B-r)  // lower right start
        bre = CGPoint(x: R-r, y: B  )  // lower right end

        bls = CGPoint(x: L+r, y: B  )  // lower left start
        ble = CGPoint(x: L,   y: B-r)  // lower left end
    }

    func leftPath(_ path:UIBezierPath) {

        let a = arrowXY // arrow point
        let r = radius
        let m = CGFloat(1) // margin

        // end points of arrow
        let am = CGPoint(x: a.x+r,   y: a.y   ) // arrow mid point
        var au = CGPoint(x: am.x+m,  y: am.y-r) // arrow upper end
        var ab = CGPoint(x: am.x+m,  y: am.y+r) // arrow below end

        // shorten commands to q_ quad curve, l_ line, s_ scrunch overlapping points
        func q_(_ p:CGPoint,_ c:CGPoint) { path.addQuadCurve(to: p, controlPoint: c) }
        func l_(_ p:CGPoint)             { path.addLine(to: p) }
        func s_(_ p0:inout CGFloat,_ p1:inout CGFloat) { if p0 > p1 { p0 = (p0+p1)/2 ; p1 = p0 } } // middle point of overlap

        s_(&ble.y, &ab.y)                       // scrunch begin of arrow, if needed
        s_(&au.y, &uls.y)                       // scrunch end of arrow if needed

        path.move(to: a)                        // start at tip of arrow
        q_(au,am) ; if au.y < uls.y { l_(uls) } // end arrow with optional line
        q_(ule,ul) ; l_(urs)                    // upper left corner w line
        q_(ure,ur) ; l_(brs)                    // upper right corner w line
        q_(bre,br) ; l_(bls)                    // below right corner w line
        q_(ble,bl) ; if ble.y < ab.y { l_(ab) } // below left corner w optional line
        q_(a,am)                                // begin arrow
        path.close()                            // close path w line to upper left

    }

    func centerPath(_ path:UIBezierPath) {

        let r = radius

        // shorten commands to q_ quad curve, l_ line, s_ scrunch overlapping points
        func q_(_ p:CGPoint,_ c:CGPoint) { path.addQuadCurve(to: p, controlPoint: c) }
        func l_(_ p:CGPoint)             { path.addLine(to: p) }

        path.move(to: uls)   // start at up left
        q_(ule,ul) ; l_(urs) // upper left corner w line
        q_(ure,ur) ; l_(brs) // upper right corner w line
        q_(bre,br) ; l_(bls) // below right corner w line
        q_(ble,bl)           // below left corner
        path.close()         // close path w line to upper left
    }

    override func draw(_ rect: CGRect) {

        let path = UIBezierPath()
        let m = CGFloat(1.5)
        let w = frame.size.width-2*m
        let h = frame.size.height-2*m
        let r = radius


        switch bubble.bubShape {
        case .above:  setCorners(U: m,   B: m+h-r, L: m,  R: m+w   ) ; abovePath(path)
        case .below:  setCorners(U: m+r, B: m+h,   L: m,  R: m+w   ) ; belowPath(path)
        case .left:   setCorners(U: m,   B: m+h,   L: m+r,R: m+w   ) ; leftPath (path)
        case .right:  setCorners(U: m,   B: m+h,   L: m,  R: m+w-r ) ; rightPath(path)
        default:      setCorners(U: m,   B: m+h,   L: m,  R: m+w   ) ; centerPath(path)
        }

        cellColor.setFill() //??//
        UIColor.white.setStroke()
        let dash: [CGFloat] = [1,2]
        path.setLineDash(dash, count:dash.count, phase: 0)
        //path.lineCapStyle = .round

        path.fill()
        path.stroke()

        let maskLayer = CAShapeLayer()
        maskLayer.frame = bounds
        maskLayer.lineWidth = 1.0
        maskLayer.strokeColor = UIColor.white.cgColor
        maskLayer.fillColor = UIColor.red.cgColor
        maskLayer.backgroundColor = UIColor.clear.cgColor
        maskLayer.path = path.cgPath

        //Don't add masks to layers already in the hierarchy!
        let superv = self.superview
        removeFromSuperview()
        layer.mask = maskLayer
        superv?.addSubview(self)
    }

}

