/* Copyright (C) 2015 Muse.com, Inc - see LICENSE.txt for licensing information */

import Foundation
import EventKit
import UIKit

extension MuEvent { // calendar, reminder
    
    func loadEvents(type:EKEntityType) {
        
    }
    /* Not Used, yet
     |
     */
    func authorizeAndLoadEvents(type:EKEntityType) {
        
        let status = EKEventStore.authorizationStatus(for: type)
        
        switch (status) {
        case EKAuthorizationStatus.notDetermined:   requestAccessToEvents(type: type)
        case EKAuthorizationStatus.authorized:      loadEvents(type: type)
        case EKAuthorizationStatus.restricted, EKAuthorizationStatus.denied:
            Log("\(#function) type:\(type) denied !!!")
        }
    }
    
    /* Not Used, yet
     |
     */
    func requestAccessToEvents(type:EKEntityType) {
        let eventStore = EKEventStore()
        eventStore.requestAccess(to: type, completion: {
            (accessGranted: Bool, error: NSError?) in
            
            if accessGranted == true {
                DispatchQueue.main.async {
                    self.loadEvents(type: type)
                }
            } else {
                DispatchQueue.main.async  {
                     Log("\(#function) type:\(type) needs permission !!!")
                    //self.needPermission(type: type)
                    
                }
            }
            } as! EKEventStoreRequestAccessCompletionHandler) // added by fixit
    }

}
