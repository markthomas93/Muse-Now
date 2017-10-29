//  KoEvent+fake.swift

import Foundation

extension KoEvents {
    
    func printEvents(_ events: [KoEvent]) {
        
        for event in events {
            
            let timeMain = KoDate.dateToString(event.bgnTime, "MM-dd h:mm")
            print(timeMain,event.title)
        }
    }
    
    func fakeDots(_ bgnTime:Int64, _ endTime:Int64) -> [KoEvent] {
        
        var events: [KoEvent] = []
        
        for d in -7 ... 7 {
            for h in 0 ..< 23 {
                events.append( KoEvent(.ekevent, String("fake \(d):\(h)"),     bDay: d,  h,00, eDay: d,  h+1,00, .white ))
            }
            events.append( KoEvent(.ekevent, String("fake 23:00)"),     bDay: d,  23,00, eDay: d+1,  0,00, .white ))
        }
        return events
    }
    
    
    func getFakeEvents(_ completion: @escaping (_ events:[KoEvent]) -> Void)  {
        
        var events : [KoEvent] = []
    
        // past events
        for d in -7...0 {
            
            if d&1 == 0 { // even day
                
                events.append( KoEvent(.ekevent, String("Sleep \(d)"), bDay:d-1,22,30, eDay: d, 5,00, .purple ))
                events.append( KoEvent(.note, String("Mood Up\(d)"),        day:d, 5,15, .blue ))
                events.append( KoEvent(.note, String("Meal A1 \(d)"),       day:d, 6,05, .blue ))
                events.append( KoEvent(.note, String("Note A \(d)"),        day:d, 9,30, .blue ))
                events.append( KoEvent(.note, String("1st A Thing with an extra long title just for kicks \(d)"),   day:d,10,10, .blue ))
                events.append( KoEvent(.note, String("2nd A Thing \(d)"),   day:d,10,50, .blue ))
                events.append( KoEvent(.note, String("3rd A Thing \(d)"),   day:d,11,20, .blue ))
                events.append( KoEvent(.note, String("Meal A2 \(d)"),       day:d,12,10, .blue ))
                events.append( KoEvent(.note, String("4th A Thing \(d)"),   day:d,13,20, .blue ))
                events.append( KoEvent(.note, String("5th A Thing \(d)"),   day:d,13,40, .blue ))
                events.append( KoEvent(.note, String("6th A Thing \(d)"),   day:d,15,22, .blue ))
                events.append( KoEvent(.note, String("Socialize \(d)"),     day:d,18,20, .blue ))
                
            }
            else  { // odd day
                events.append( KoEvent(.ekevent, String("Sleep  \(d)"), bDay:d,00,30, eDay:d, 5,45, .purple ))
                events.append( KoEvent(.note, String("Mood Dn \(d)"),       day:d, 5,30, .blue ))
                events.append( KoEvent(.note, String("Meal B1 \(d)"),       day:d, 6,20, .blue ))
                events.append( KoEvent(.note, String("Good Workout \(d)"),  day:d, 9,50, .blue ))
                events.append( KoEvent(.note, String("1st B Item \(d)"),    day:d,10,40, .blue ))
                events.append( KoEvent(.note, String("2nd B Item \(d)"),    day:d,11,50, .blue ))
                events.append( KoEvent(.note, String("Meal B2  \(d)"),      day:d,12,10, .blue ))
                events.append( KoEvent(.note, String("3rd B Item \(d)"),    day:d,13,20, .blue ))
                events.append( KoEvent(.note, String("4th B Item \(d)"),    day:d,15,50, .blue ))
                events.append( KoEvent(.note, String("Exercice B \(d)"),    day:d,18,20, .blue ))
            }
        }
        
        // future events
        
        for d in 0 ..< 7 {
            
            if d&1 == 0 { // even days
                
                events.append( KoEvent(.ekevent, String("Breakfast \(d)"),    bDay:d,  5,30, eDay: d,  6,00, .violet ))
                events.append( KoEvent(.ekevent, String("Exercise \(d)"),     bDay:d,  6,30, eDay: d,  9,30, .red    ))
                events.append( KoEvent(.ekevent, String("Code A\(d)"),        bDay:d, 10,00, eDay: d, 11,00, .blue   ))
                events.append( KoEvent(.ekevent, String("Triage \(d)"),       bDay:d, 11,00, eDay: d, 11,30, .orange ))
                events.append( KoEvent(.ekevent, String("Standup \(d)"),      bDay:d, 11,45, eDay: d, 12,00, .orange ))
                events.append( KoEvent(.ekevent, String("Lunch \(d)"),        bDay:d, 12,00, eDay: d, 13,00, .violet ))
                events.append( KoEvent(.ekevent, String("Code P\(d)"),        bDay:d, 13,00, eDay: d, 13,30, .blue   ))
                events.append( KoEvent(.ekevent, String("Office Hours \(d)"), bDay:d, 16,00, eDay: d, 17,00, .yellow ))
                events.append( KoEvent(.ekevent, String("Meetup \(d)"),       bDay:d, 18,00, eDay: d, 21,00, .green  ))
                events.append( KoEvent(.ekevent, String("Sleep \(d)"),        bDay:d, 22,00, eDay:d+1, 5,00, .purple ))
            }
            else  { // odd day
                
                events.append( KoEvent(.ekevent, String("Breakfast \(d)"),    bDay: d,  7,00, eDay:d,  7,30, .violet ))
                events.append( KoEvent(.ekevent, String("Stretch \(d)"),      bDay: d,  7,30, eDay:d,  8,00, .red    ))
                events.append( KoEvent(.ekevent, String("Code A\(d)"),        bDay: d, 10,00, eDay:d, 12,00, .blue   ))
                events.append( KoEvent(.ekevent, String("Lunch \(d)"),        bDay: d, 12,00, eDay:d, 13,00, .green  ))
                events.append( KoEvent(.ekevent, String("Code P\(d)"),        bDay: d, 13,00, eDay:d, 16,30, .blue   ))
                events.append( KoEvent(.ekevent, String("Meetup \(d)"),       bDay: d, 18,30, eDay:d, 21,30, .green  ))
                events.append( KoEvent(.ekevent, String("Sleep \(d)"),        bDay: d, 22,00, eDay:d+1,5,00, .purple ))
            }
        }
        // events.append( KoEvent(.ekevent, "Conflict1",     bDay: 0,  9,30, eDay: 0,10,30, .Orange  ) )
        // events.append( KoEvent(.ekevent, "Conflict2",     bDay: 0, 10,00, eDay: 0,12,00, .Yellow  ) )
        let result = events + getNearbyEvents()
        completion(result)
    }
    
    func getNearbyEvents() -> [KoEvent]  {
        
        var events : [KoEvent] = []
        
        let cal = Calendar.current
        let comps = cal.dateComponents([.year, .month, .day, .hour, .minute, .timeZone], from:Date())
        let date = cal.date(from: comps) // current time to nearest minute
        let time = trunc((date?.timeIntervalSince1970)!)
        
        events.append(KoEvent(.ekevent, String("Start - 16 "), time, deltaMin:-16))
        events.append(KoEvent(.ekevent, String("Start - 8 "), time, deltaMin:-8))
        events.append(KoEvent(.ekevent, String("Start - 6 "), time, deltaMin:-6))
        events.append(KoEvent(.ekevent, String("Start - 4 "), time, deltaMin:-4))
        //events.append(KoEvent(.ekevent, String("Start - 2 "), time, deltaMin:-2))
        //events.append(KoEvent(.ekevent, String("Start + 2 "), time, deltaMin:2))
        events.append(KoEvent(.ekevent, String("Start + 4 "), time, deltaMin:4))
        events.append(KoEvent(.ekevent, String("Start + 6 "), time, deltaMin:6))
        events.append(KoEvent(.ekevent, String("Start + 8 "), time, deltaMin:8))
        events.append(KoEvent(.ekevent, String("Start + 16 "), time, deltaMin:16))
        return events
    }
}
