//
//  MuDrawBubble.swift
//  MuseNow
//
//  Created by warren on 12/14/17.
//  Copyright © 2017 Muse. All rights reserved.
//

import Foundation
import UIKit

public enum BubShape { case
    center, above, below, left, right,
    diptych12, diptych22,
    triptych13, triptych23,triptych33
}

class MuDrawBubble: UIView {

    var bubShape = BubShape.above
    var bubFrame = CGRect.zero
    var radius  = CGFloat(8)
    var arrowXY = CGPoint.zero

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

    private var childX = CGFloat(0) // family[2].frame.origin.x
    private var childY = CGFloat(0) // family[2].frame.origin.y
    private var childW = CGFloat(0) // family[2].frame.size.width
    private var childH = CGFloat(0) // amily[2].frame.size.height

    private var fam0: UIView!
    private var fam1: UIView!
    private var fam2: UIView!

    public var viewPoint = CGPoint.zero // used for animation

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override init(frame:CGRect) {
        super.init(frame: frame)
    }
    func makeBubble(_ bubShape_:BubShape, _ size: CGSize,_ radius_: CGFloat,_ family:[UIView]) {

        bubShape = bubShape_
        radius = radius_

        fam0 = family[0] // grand
        fam1 = family[1] // parent
        fam2 = family[2] // child

        childX = fam2.frame.origin.x
        childY = fam2.frame.origin.y
        childW = fam2.frame.size.width
        childH = fam2.frame.size.height

        switch bubShape {
        case .above:  makeAbove(size, family)
        case .below:  makeBelow(size, family)
        case .left:   makeLeft(size, family)
        case .right:  makeRight(size, family)
        default:      makeCenter(size, family)
        }

        print("\(bubShape) bub:\(bubFrame.origin) viewPoint:\(viewPoint) arrow:\(arrowXY)")

        self.frame = bubFrame
        isUserInteractionEnabled = true
    }

    /**
     Shift frame to fit in screen
     - parameter fx: from child x
     - parameter fy: from child y
     - parameter dx: delta x to add to viewPoint
     - parameter dy: delta y to add to viewPoint
     - parameter w:  width
     - parameter h:  height

     - returns: ViewPoint from which to spring bubble
     */
    func makeBubFrame(fx: CGFloat, fy: CGFloat,
                      dx: CGFloat, dy: CGFloat,
                      w:  CGFloat, h:  CGFloat) {

        let testPoint = CGPoint(x: fx, y: fy)
        viewPoint = fam0.convert(testPoint, from: fam1)
        let x = viewPoint.x + dx
        let y = viewPoint.y + dy

        let bW = UIScreen.main.fixedCoordinateSpace.bounds.size.width
        let bH = UIScreen.main.fixedCoordinateSpace.bounds.size.height
        bubFrame = CGRect(x: max(0,x+w < bW ? x : bW-w),
                          y: max(0,y+h < bH ? y : bH-h),
                          width:w, height:h)
    }

    func makeRight(_ size: CGSize,_ family:[UIView]) {

        makeBubFrame(fx: childX,
                     fy: childY + childH / 2,

                     dx: -size.width - radius,
                     dy: -size.height / 2,
                     w:   size.width + radius,
                     h:   size.height)

        arrowXY = CGPoint(x: viewPoint.x - bubFrame.origin.x,
                          y: viewPoint.y - bubFrame.origin.y)
    }

    func makeLeft(_ size: CGSize,_ family:[UIView]) {

        makeBubFrame(fx: childX + childW,
                     fy: childY + childH / 2,
                     dx: radius,
                     dy: -size.height / 2,
                     w:   size.width + radius,
                     h:   size.height)

        arrowXY = CGPoint(x: 0,
                          y: viewPoint.y - bubFrame.origin.y)
    }

    func makeBelow(_ size: CGSize,_ family:[UIView]) {

        makeBubFrame(fx: childX + childW / 2,
                     fy: childY + childH,

                     dx: -size.width / 2,
                     dy: 0,
                     w: size.width,
                     h: size.height + radius)

        arrowXY = CGPoint(x: viewPoint.x - bubFrame.origin.x,
                          y: 0)
    }

    func makeAbove(_ size: CGSize,_ family:[UIView]) {

        makeBubFrame(fx: childX + childW / 2,
                     fy: childY,

                     dx: -size.width / 2,
                     dy: -size.height - radius,
                     w:   size.width,
                     h:   size.height + radius)

        arrowXY = CGPoint(x: viewPoint.x - bubFrame.origin.x,
                          y: viewPoint.y - bubFrame.origin.y)
    }

    func makeCenter(_ size: CGSize,_ family:[UIView]) {

        func makeFrame(_ position:CGFloat, _ count: CGFloat) {

            let totalW = fam0.frame.size.width
            let totalH = fam0.frame.size.height
            let subM = CGFloat(4) // sub margin
            let subW = (totalW-(count-1)*subM) / count
            let subH = size.width/size.height * subW
            let x = (position-1) * (subW + subM)
            let y = (totalH-subH)/2

            makeBubFrame(fx: x+subW/2, fy: y+subH/2,
                         dx: -subW/2,  dy: -subH/2,
                         w:   subW,    h:   subH)
        }
        switch bubShape {
        case .diptych12:  makeFrame(1,2)
        case .diptych22:  makeFrame(2,2)
        case .triptych13: makeFrame(1,3)
        case .triptych23: makeFrame(2,3)
        case .triptych33: makeFrame(3,3)

        default:
            makeBubFrame(fx: childX + childW / 2,
                         fy: childY + childH / 2,

                         dx: -size.width / 2,
                         dy: -size.height / 2,
                         w:   size.width,
                         h:   size.height)
        }

    }

    // paths ---------------------------------------------------------

    func belowPath(_ path:UIBezierPath) {

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

        path.move(to: uls)                      // start at upper left
        q_(ule,ul) ; l_(urs)                    // upper left corner with line
        q_(ure,ur) ; l_(brs)                    // upper rigth corner with line
        s_(&ar.x,&bre.x)                        // scrunch start of arrow if needed
        s_(&bls.x,&al.x)                        // scrunch end of arrow if needed
        q_(bre,br) ; if ar.x < bre.x { l_(ar) } // below right corner w optional line
        q_(a,am)                                // start of arrow
        q_(al,am) ; if bls.x < al.x { l_(bls) } // end of arrow with optional line
        q_(ble,bl)                              // below left corner
        path.close()                            // close path with line to upper left
    }

    func abovePath(_ path:UIBezierPath) {

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

        path.move(to: uls)                      // start at upper left
        s_(&ule.x,&al.x)                        // scrunch begin of arrow, if needed
        s_(&ar.x,&urs.x)                        // scrunch end of arrow, if needed
        q_(ule,ul) ; if ule.x < al.x { l_(al) } // upper left corner w optional line
        q_(a,am)                                // begin arrow
        q_(ar,am) ; if urs.x > ar.x { l_(urs) } // end arrow with optiona line
        q_(ure,ur) ; l_(brs)                    // upper right corner with line
        q_(bre,br) ; l_(bls)                    // below right corner with line
        q_(ble,bl)                              // below left corner with line
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

        path.move(to: uls)                      // start at upper left
        q_(ule,ul) ; l_(urs)                    // upper left start to end
        s_(&ure.y, &au.y)                       // scrunch begin start of arrow if needed
        s_(&ab.y,&brs.y )                       // sceunch end of arrow if needed
        q_(ure,ur) ; if ure.y < au.y { l_(au) } // upper right corner w optional line to arrow
        q_(a,am)                                // beginning of arrow
        q_(ab,am) ; if ab.y < brs.y { l_(brs) } // end of arrow w option line to below right
        q_(bre,br) ; l_(bls)                    // below right corner w line
        q_(ble,bl)                              // bllow left corner
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

        path.move(to: uls)                      // start at up left
        q_(ule,ul) ; l_(urs)                    // upper left corner w line
        q_(ure,ur) ; l_(brs)                    // upper right corner w line
        q_(bre,br) ; l_(bls)                    // below right corner w line
        s_(&ble.y, &ab.y)                       // scrunch begin of arrow, if needed
        s_(&au.y, &uls.y)                       // scrunch end of arrow if needed
        q_(ble,bl) ; if ble.y < ab.y { l_(ab) } // below left corner w optional line
        q_(a,am)                                // begin arrow
        q_(au,am) ; if au.y < uls.y { l_(uls) } // end arrow with optional line
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
        let w = frame.size.width-2
        let h = frame.size.height-2
        let r = radius
        let m = CGFloat(1)

        switch bubShape {
        case .above:  setCorners(U: m,   B: m+h-r, L: m,  R: m+w   ) ; belowPath(path)
        case .below:  setCorners(U: m+r, B: m+h,   L: m,  R: m+w   ) ; abovePath(path)
        case .left:   setCorners(U: m,   B: m+h,   L: m+r,R: m+w   ) ; leftPath (path)
        case .right:  setCorners(U: m,   B: m+h,   L: m,  R: m+w-r ) ; rightPath(path)
        default:      setCorners(U: m,   B: m+h,   L: m,  R: m+w   ) ; centerPath(path)
        }

        UIColor.black.setFill()
        UIColor.white.setStroke()

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

