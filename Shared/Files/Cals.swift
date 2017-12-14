//
//  Cals.swift


import Foundation
import EventKit

class Cals: FileSync {
    
    static let shared = Cals()
    
    var ekCals = [EKCalendar]()         // event kit calendars minus holidays and contacts
    var cals = [Cal!]()                  // muse translated version of EKCalendar
    var idCal = [String:Cal!]()         // retreive cal from its calendarID
    var sourceCals = [String:[Cal!]]()  // each data source may have several calendars
    

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
    

  
    func updateCalsArchive() {

        if archiveArray(cals,Date().timeIntervalSince1970) {
            Actions.shared.doRefresh(/*isSender*/false)
            sendSyncFile()
        }
    }

    /// find and update event Marker
    func updateMark(_ calId:String,_ isOn:Bool) {
        for cali in cals {
            if cali?.calId == calId {
                cali!.isOn = isOn
                updateCalsArchive()
                return
            }
        }
    }

}
