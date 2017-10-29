//
//  Cals.swift


import Foundation
import EventKit

class Cals: FileSync {
    
    static let shared = Cals()
    
    var ekCals = [EKCalendar]()
    var sourceCals = [String:[Cal!]]()
    var idCal = [String:Cal!]()
    var cals = [Cal]()
    
    override init() {
        super.init()
        fileName = "Cals.plist"
    }
    
    // EKCalendar --------------------------------------------

    /// read selected calendars from file and filter from current set of eventKit Calendars
    func unarchiveCals(_ store: EKEventStore, _ completion: @escaping () ->Void) {
        
        // clear everything
        ekCals.removeAll()
        sourceCals.removeAll()
        cals.removeAll()
        
        // current set of EventKit calendars
        let ekCalendars = store.calendars(for: .event)
        for ekCal in ekCalendars {
            // add calDav calenders that are not Holidays or Contacts
            if   ekCal.type == .calDAV,
                !ekCal.title.hasPrefix("Holidays"),
                !ekCal.title.hasPrefix("Contacts") {
                
                ekCals.append(ekCal)
                
                // print ("\(ekCal.source.title) : \(ekCal.title)")
                
                let cal = Cal(ekCal)
                cals.append(cal)
                idCal[cal.calId] = cal
                
                // update sourceCals :[String:[Cal]]
                if var array = sourceCals[cal.source] {
                    array.append(cal)
                    sourceCals[cal.source] = array
                }
                else {
                    sourceCals[cal.source] = [cal]
                }
            }
        }
        // apply archived calendars isOn preferences
        unarchiveArray() { array in
            let fileCals = array as! [Cal]
            for fileCal in fileCals {
                
                if let memCal = self.idCal[fileCal.calId] {
                    memCal.isOn = fileCal.isOn
                }
            }
            completion()
        }
    }

    
    // File -------------------------------------------------
    

    /// file was sent from other device
    override func receiveFile(_ data:Data, _ fileTime_: TimeInterval, completion: @escaping () -> Void) {
        
        let fileTime = trunc(fileTime_)
        
        printLog ("⧉ Cals::\(#function) fileTime:\(fileTime) -> memoryTime:\(memoryTime)")
        
        if memoryTime < fileTime {
            memoryTime = fileTime
            cals = NSKeyedUnarchiver.unarchiveObject(with:data as Data) as! [Cal]
            cals.sort { $0.calId < $1.calId }
            archiveArray(cals,fileTime)
            completion()
        }
    }
    
    /// find and update event Marker
    func updateMark(_ calId:String,_ isOn:Bool) {
        for cali in cals {
            if cali.calId == calId {
                cali.isOn = isOn
                archiveArray(cals,Date().timeIntervalSince1970)
                Actions.shared.doRefresh(/*isSender*/false)
                sendSyncFile()
                return
            }
        }
    }

}
