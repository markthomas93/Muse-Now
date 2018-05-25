//
//  Cals.swift


import Foundation
import EventKit

class Cals: FileSync {
    
    static let shared = Cals()
    
    var ekCals = [EKCalendar]()         // event kit calendars minus holidays and contacts
    var cals = [Cal]()                  // muse translated version of EKCalendar

    /// WARNING, changing ! to ? is problematic, need shared pointer to same object, removing ! doesn't work!!!!
    var idCal = [String:Cal!]()         // retreive cal from its calendarID
    var sourceCals = [String:[Cal!]]()  // each data source may have several calendars

    override init() {
        super.init()
        fileName = "Calendars.json"
    }
    
    // EKCalendar --------------------------------------------

    /// read selected calendars from file and filter from current set of eventKit Calendars
    func unarchiveCals(_ store: EKEventStore, _ done: @escaping () ->Void) {
        
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
                !ekCal.title.hasPrefix("Contacts") { //Log("📅 \(ekCal.source.title) : \(ekCal.title)")

                ekCals.append(ekCal)

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
        unarchiveData() { data in

            if  let data = data,
                let fileCals = try? JSONDecoder().decode([Cal].self, from:data) {

                for fileCal in fileCals {
                    if let memCal = self.idCal[fileCal.calId] {
                        memCal?.isOn = fileCal.isOn
                    }
                }
                done()
            }
            else {
                done()
            }
        }
    }

    // File -------------------------------------------------

    
    func archiveCals(done:@escaping CallVoid) {

        if let data = try? JSONEncoder().encode(cals) {

            let _ = saveData(data)
            Actions.shared.doRefresh(/*isSender*/false)
            done()
        }
        else {
            done()
        }
    }


    /// find and update event Marker
    func updateMark(_ calId:String,_ isOn:Bool) {
        for cali in cals {
            if cali.calId == calId {
                cali.isOn = isOn
                archiveCals {}
                return
            }
        }
    }

}
