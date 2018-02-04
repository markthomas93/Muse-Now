//  View+Extension.swift

import UIKit

extension UIView {

    func roundCorners(_ corners:UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        self.layer.mask = mask
    }

    /**
     make rectangular or eliptical path
     - parameter m: margin
     - parameter w: width
     - parameter h: height
     - parameter r: radius
     */

    func makeRoundRectPath(m:CGFloat, w:CGFloat,h:CGFloat,r:CGFloat) -> CGMutablePath {

         let path = CGMutablePath()

        func drawRoundedRect() {
            // 4 corner control points

            var ul  = CGPoint(x: m,     y: m) // upper left control point
            var ur  = CGPoint(x: m+w,   y: m) // upper right control point
            var br  = CGPoint(x: m+w,   y: m+h) // lower right control point
            var bl  = CGPoint(x: m,     y: m+h) // lower left control point

            // 8 line segment start end

            var uls = CGPoint(x: m,     y: m+r  )  // upper left start
            var ule = CGPoint(x: m+r,   y: m    )  // upper left end

            var urs = CGPoint(x: m+w-r, y: m    )  // upper right start
            var ure = CGPoint(x: m+w,   y: m+r  )  // upper right end

            var brs = CGPoint(x: m+w,   y: m+h-r)  // lower right start
            var bre = CGPoint(x: m+w-r, y: m+h  )  // lower right end

            var bls = CGPoint(x: m+r,   y: m+h  )  // lower left start
            var ble = CGPoint(x: m,     y: m+h-r)  // lower left end

            // shorten commands to q_ quad curve, l_ line, s_ scrunch overlapping points
            func q_(_ p:CGPoint,_ c:CGPoint) { path.addQuadCurve(to: p, control: c) }
            func l_(_ p:CGPoint)             { path.addLine(to: p) }

            path.move(to: uls)   // start at up left
            q_(ule,ul) ; l_(urs) // upper left corner w line
            q_(ure,ur) ; l_(brs) // upper right corner w line
            q_(bre,br) ; l_(bls) // below right corner w line
            q_(ble,bl) ; l_(uls) // below left corner w line
        }
        let width  = frame.size.width
        let height = frame.size.height
        let sideRadius = ( r == width/2 || r == height/2)

        if sideRadius { path.addEllipse(in: self.frame) }
        else          { drawRoundedRect() }

        return path
    }

    func addSolidBorder(color: UIColor, radius:CGFloat) {
        let lineWidth = CGFloat(1)
        let m = lineWidth // margin
        let frameSize = self.frame.size
        let width  = frame.size.width
        let height = frame.size.height
        let path = makeRoundRectPath(m: m,
                                     w: width - 2*m,
                                     h: height - 2*m,
                                     r: radius)

        layer.sublayers?.forEach() { if $0.name == "RoundBorder" { $0.removeFromSuperlayer() }}

        let shapeLayer: CAShapeLayer = CAShapeLayer()
        let shapeRect = CGRect(x: 0, y: 0, width: width, height: height)

        shapeLayer.name = "RoundBorder"
        shapeLayer.bounds = shapeRect
        shapeLayer.position = CGPoint(x: frameSize.width / 2, y: frameSize.height / 2)

        shapeLayer.strokeColor = color.cgColor
        shapeLayer.lineWidth = lineWidth
        shapeLayer.lineJoin = kCALineJoinRound
        shapeLayer.path = path

        self.layer.mask = shapeLayer

    }
    func addDashBorder(color: UIColor, radius:CGFloat) {
        let lineWidth = CGFloat(1.5)
        let m = lineWidth // margin
        let width  = frame.size.width
        let height = frame.size.height
        let path = makeRoundRectPath(m: m,
                                     w: width - 2*m,
                                     h: height - 2*m,
                                     r: radius)


        layer.sublayers?.forEach() { if $0.name == "DashBorder" { $0.removeFromSuperlayer() }}
        backgroundColor = .clear

        let shapeLayer: CAShapeLayer = CAShapeLayer()
        let shapeRect = CGRect(x: 0, y: 0, width:width, height:height)

        shapeLayer.name = "DashBorder"
        shapeLayer.bounds = shapeRect
        shapeLayer.position = CGPoint(x: width / 2, y: height / 2)
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.strokeColor = color.cgColor
        shapeLayer.lineWidth = lineWidth
        shapeLayer.lineJoin = kCALineJoinRound
        shapeLayer.lineDashPattern = [1, 2]

        shapeLayer.path = path

        self.layer.addSublayer(shapeLayer)
    }
}

