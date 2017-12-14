//
//  Calendar.swift

import Foundation
import EventKit
import UIKit

@objc(Cal) // share data format for phone and watch devices
public class Cal: NSObject, NSCoding {
    
    var calId  = "id"
    var source = "source"
    var title  = "title"
    var isOn = true
    var color = UIColor.gray.cgColor
    
    
    required public init?(coder decoder: NSCoder) {
        super.init()
        calId  = decoder.decodeObject(forKey:"calId") as! String
        source = decoder.decodeObject(forKey:"source") as! String
        title  = decoder.decodeObject(forKey:"title") as! String
        isOn   = decoder.decodeBool  (forKey:"isOn")
        color  = CGColor(colorSpace: CGColorSpaceCreateDeviceRGB(),  components: decoder.decodeObject(forKey:"color") as! [CGFloat])!
    }
    
    public func encode(with aCoder: NSCoder) {
        aCoder.encode(calId,  forKey:"calId")
        aCoder.encode(source, forKey:"source")
        aCoder.encode(title,  forKey:"title")
        aCoder.encode(isOn,   forKey:"isOn")
        aCoder.encode( [CGFloat](UnsafeBufferPointer(start: color.components, count: 4)), forKey: "color")
    }
    
    init(_ ekCal: EKCalendar) {
        calId  = ekCal.calendarIdentifier
        source = ekCal.source.title
        title  = ekCal.title
        isOn   = true
        color  = ekCal.cgColor
    }
    override init () {
        super.init()
    }
    
    convenience init (cal: Cal!) {
        self.init()
        calId = cal.calId
        source = cal.source
        title = cal.title
        color = cal.color
        isOn = true
    }
    /// find and update event Marker
    func updateMark(_ isOn_:Bool) {
        isOn = isOn_
        Cals.shared.updateCalsArchive()
    }

}
