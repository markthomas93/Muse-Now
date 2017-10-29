//  Haptic.swift

import WatchKit
import UIKit

public enum HapticType : Int { case  success,failure,start,stop,click }

class Haptic {
    
    static func play(_ type:HapticType) {
        
        #if os(iOS)
            
            switch type {
            case .success:  UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
            default:        UIImpactFeedbackGenerator(style: .light).impactOccurred()
            }
            
        #elseif os(watchOS)
            
            switch type {
            case .success: WKInterfaceDevice.current().play(.success)
            case .click:   WKInterfaceDevice.current().play(.click)
            case .start:   WKInterfaceDevice.current().play(.start)
            case .stop:    WKInterfaceDevice.current().play(.stop)
            case .failure: WKInterfaceDevice.current().play(.failure)
            }
            
        #endif
    }
}
