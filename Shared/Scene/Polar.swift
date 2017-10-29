
import UIKit

func dotRadius(_ radius: CGFloat, _ now˚ : CGFloat, _ start˚: CGFloat, dump: Bool) ->
    (cenRadius:CGFloat, dotRadius:CGFloat) {
        
        let unitRadius = (CGFloat.pi*2)/48 // radius of 1/24 of a day
        let unitFactor = 1 - unitRadius * 1.2 //* 0.92 // * 1.6 // * 1.76
        let circumNav = fabs(now˚ - start˚ + 15) / 360.0    // number of cicumnavigations, starting from first point
        let circFactor = pow(unitFactor, circumNav)
        
        let cenRadius = radius * circFactor
        let dotRadius = cenRadius * unitRadius
        
        return (cenRadius, dotRadius)
}

func PolarPoint2(_ center:CGPoint, _ angle:CGFloat, _ length:CGFloat) -> CGPoint {
    
    let dX: CGFloat = length * cos(angle)
    let dY: CGFloat = length * sin(angle)
    
    let point: CGPoint = CGPoint(x: center.x + dX, y: center.y + dY);
    return point;
}
