//  MuEvent+fake.swift

import Foundation

extension MuEvents {
    
    func printEvents(_ events: [MuEvent]) {
        
        for event in events {
            
            let timeMain = MuDate.dateToString(event.bgnTime, "MM-dd h:mm")
            print(timeMain,event.title)
        }
    }
    
    func fakeDots(_ bgnTime:Int64, _ endTime:Int64) -> [MuEvent] {
        
        var events: [MuEvent] = []
        
        for d in -7 ... 7 {
            for h in 0 ..< 23 {
                events.append( MuEvent(.ekevent, String("fake \(d):\(h)"),     bDay: d,  h,00, eDay: d,  h+1,00, .white ))
            }
            events.append( MuEvent(.ekevent, String("fake 23:00)"),     bDay: d,  23,00, eDay: d+1,  0,00, .white ))
        }
        return events
    }
    
    
    func getFakeEvents(_ completion: @escaping (_ events:[MuEvent]) -> Void)  {
        
        var events : [MuEvent] = []
    
        // past events
        for d in -7...0 {
            
            if d&1 == 0 { // even day
                
                events.append( MuEvent(.ekevent, String("Sleep \(d)"), bDay:d-1,22,30, eDay: d, 5,00, .purple ))
                events.append( MuEvent(.note, String("Mood Up\(d)"),        day:d, 5,15, .blue ))
                events.append( MuEvent(.note, String("Meal A1 \(d)"),       day:d, 6,05, .blue ))
                events.append( MuEvent(.note, String("Note A \(d)"),        day:d, 9,30, .blue ))
                events.append( MuEvent(.note, String("1st A Thing with an extra long title just for kicks \(d)"),   day:d,10,10, .blue ))
                events.append( MuEvent(.note, String("2nd A Thing \(d)"),   day:d,10,50, .blue ))
                events.append( MuEvent(.note, String("3rd A Thing \(d)"),   day:d,11,20, .blue ))
                events.append( MuEvent(.note, String("Meal A2 \(d)"),       day:d,12,10, .blue ))
                events.append( MuEvent(.note, String("4th A Thing \(d)"),   day:d,13,20, .blue ))
                events.append( MuEvent(.note, String("5th A Thing \(d)"),   day:d,13,40, .blue ))
                events.append( MuEvent(.note, String("6th A Thing \(d)"),   day:d,15,22, .blue ))
                events.append( MuEvent(.note, String("Socialize \(d)"),     day:d,18,20, .blue ))
                
            }
            else  { // odd day
                events.append( MuEvent(.ekevent, String("Sleep  \(d)"), bDay:d,00,30, eDay:d, 5,45, .purple ))
                events.append( MuEvent(.note, String("Mood Dn \(d)"),       day:d, 5,30, .blue ))
                events.append( MuEvent(.note, String("Meal B1 \(d)"),       day:d, 6,20, .blue ))
                events.append( MuEvent(.note, String("Good Workout \(d)"),  day:d, 9,50, .blue ))
                events.append( MuEvent(.note, String("1st B Item \(d)"),    day:d,10,40, .blue ))
                events.append( MuEvent(.note, String("2nd B Item \(d)"),    day:d,11,50, .blue ))
                events.append( MuEvent(.note, String("Meal B2  \(d)"),      day:d,12,10, .blue ))
                events.append( MuEvent(.note, String("3rd B Item \(d)"),    day:d,13,20, .blue ))
                events.append( MuEvent(.note, String("4th B Item \(d)"),    day:d,15,50, .blue ))
                events.append( MuEvent(.note, String("Exercice B \(d)"),    day:d,18,20, .blue ))
            }
        }
        
        // future events
        
        for d in 0 ..< 7 {
            
            if d&1 == 0 { // even days
                
                events.append( MuEvent(.ekevent, String("Breakfast \(d)"),    bDay:d,  5,30, eDay: d,  6,00, .violet ))
                events.append( MuEvent(.ekevent, String("Exercise \(d)"),     bDay:d,  6,30, eDay: d,  9,30, .red    ))
                events.append( MuEvent(.ekevent, String("Code A\(d)"),        bDay:d, 10,00, eDay: d, 11,00, .blue   ))
                events.append( MuEvent(.ekevent, String("Triage \(d)"),       bDay:d, 11,00, eDay: d, 11,30, .orange ))
                events.append( MuEvent(.ekevent, String("Standup \(d)"),      bDay:d, 11,45, eDay: d, 12,00, .orange ))
                events.append( MuEvent(.ekevent, String("Lunch \(d)"),        bDay:d, 12,00, eDay: d, 13,00, .violet ))
                events.append( MuEvent(.ekevent, String("Code P\(d)"),        bDay:d, 13,00, eDay: d, 13,30, .blue   ))
                events.append( MuEvent(.ekevent, String("Office Hours \(d)"), bDay:d, 16,00, eDay: d, 17,00, .yellow ))
                events.append( MuEvent(.ekevent, String("Meetup \(d)"),       bDay:d, 18,00, eDay: d, 21,00, .green  ))
                events.append( MuEvent(.ekevent, String("Sleep \(d)"),        bDay:d, 22,00, eDay:d+1, 5,00, .purple ))
            }
            else  { // odd day
                
                events.append( MuEvent(.ekevent, String("Breakfast \(d)"),    bDay: d,  7,00, eDay:d,  7,30, .violet ))
                events.append( MuEvent(.ekevent, String("Stretch \(d)"),      bDay: d,  7,30, eDay:d,  8,00, .red    ))
                events.append( MuEvent(.ekevent, String("Code A\(d)"),        bDay: d, 10,00, eDay:d, 12,00, .blue   ))
                events.append( MuEvent(.ekevent, String("Lunch \(d)"),        bDay: d, 12,00, eDay:d, 13,00, .green  ))
                events.append( MuEvent(.ekevent, String("Code P\(d)"),        bDay: d, 13,00, eDay:d, 16,30, .blue   ))
                events.append( MuEvent(.ekevent, String("Meetup \(d)"),       bDay: d, 18,30, eDay:d, 21,30, .green  ))
                events.append( MuEvent(.ekevent, String("Sleep \(d)"),        bDay: d, 22,00, eDay:d+1,5,00, .purple ))
            }
        }
        // events.append( MuEvent(.ekevent, "Conflict1",     bDay: 0,  9,30, eDay: 0,10,30, .Orange  ) )
        // events.append( MuEvent(.ekevent, "Conflict2",     bDay: 0, 10,00, eDay: 0,12,00, .Yellow  ) )
        let result = events + getNearbyEvents()
        completion(result)
    }

    /**
    Add events before and after current time for debugging shifting timeEvent
     */
    func getNearbyEvents() -> [MuEvent]  {
        
        var events : [MuEvent] = []
        
        let cal = Calendar.current
        let comps = cal.dateComponents([.year, .month, .day, .hour, .minute, .timeZone], from:Date())
        let date = cal.date(from: comps) // current time to nearest minute
        let time = trunc((date?.timeIntervalSince1970)!)
        
        events.append(MuEvent(.ekevent, String("Start - 16 "), time, deltaMin:-16))
        events.append(MuEvent(.ekevent, String("Start - 8 "), time, deltaMin:-8))
        events.append(MuEvent(.ekevent, String("Start - 6 "), time, deltaMin:-6))
        events.append(MuEvent(.ekevent, String("Start - 4 "), time, deltaMin:-4))
        //events.append(MuEvent(.ekevent, String("Start - 2 "), time, deltaMin:-2))
        //events.append(MuEvent(.ekevent, String("Start + 2 "), time, deltaMin:2))
        events.append(MuEvent(.ekevent, String("Start + 4 "), time, deltaMin:4))
        events.append(MuEvent(.ekevent, String("Start + 6 "), time, deltaMin:6))
        events.append(MuEvent(.ekevent, String("Start + 8 "), time, deltaMin:8))
        events.append(MuEvent(.ekevent, String("Start + 16 "), time, deltaMin:16))
        return events
    }
}
