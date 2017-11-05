
import Foundation

class DayHour {
    
    static let shared = DayHour()
        
    let days     = 7
    let hours    = 24
    let maxIndex = 7*24
    
    var day      = 0
    var hour     = 0
    var time0    = TimeInterval(0) // UTC time at top of current hour
    var hour0    = 0 // which hour is the starting hour
    var weekday0 = 0 // day of week, starting on Sunday
    var weekday  = 0
    var index    = 0
    
    
     let hourSpeak = ["Midnight","1 am","2 am","3 am","4 am","5 am",
                     "6 am","7 am","8 am","9 am","10 am","11 am",
                     "Noon","1 pm","2 pm","3 pm","4 pm","5 pm",
                     "6 pm","7 pm","8 pm","9 pm","10 pm","11 pm"]
    
    let hourTitle = ["Dark","1 am","2 am","3 am","4 am","5 am",
                     "6 am","7 am","8 am","9 am","10 am","11 am",
                     "Noon","1 pm","2 pm","3 pm","4 pm","5 pm",
                     "6 pm","7 pm","8 pm","9 pm","10 pm","11 pm"]
    
    let daySpeak = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
    let dayTitle = ["Sun",    "Mon",    "Tue",     "Wed",        "Thur",    "Fri",    "Sat"]
    
    func getIndex() -> Int {
        index = day * hours + (hour - hour0)
        return index
    }
    func getIndexForTime(_ time: TimeInterval) -> Int {
         return Int((time - time0)/3600.0)
    }
    func setIndexForEvent(_ event:MuEvent) {
        let relativeHour =  getIndexForTime(event.bgnTime)
        setIndex(relativeHour)
    }
    
    func setIndex(_ index_ : Int) {

        // let indexPrev = index, dayPrev = day, hourPrev = hour // for print
        
        index = max(1-maxIndex,min(maxIndex-1, index_))
        hour = (hour0 + index) % hours
        day  = (hour0 + index) / hours
        if hour < 0 {
            hour += 24
            day -= 1
        }
        weekday = (7 + weekday0 - 1 + day) % 7 // which day of week
        
        //print ("⌛︎ setIndex  index(\(indexPrev) → \(index)) day(\(dayPrev) → \(day)) hour(\(hourPrev) → \(hour))")
     }
    
    @discardableResult
    /* set base for current hour and day
     /// - via: Scene.(sceneDidLoad updateSceneFinish)
     */
    func updateTime() -> Bool {
        let prevTime0 = time0
        time0    = MuDate.relativeHour(0).timeIntervalSince1970
        hour0    = Calendar.current.component(.hour,    from: Date())
        weekday0 = Calendar.current.component(.weekday, from: Date())
        return time0 != prevTime0
    }
    
    func getDowSpeak() -> String {
        switch day {
        case Int.min ..< -1: return "Last " + daySpeak[weekday]
        case -1: return "Yesterday"
        case  0: return "Today"
        case  1: return "Tomorrow"
        case 2 ... Int.max : return daySpeak[weekday]
        default: return ""
        }
    }
    
    func getHourSpeak() -> String {
        return hourSpeak[hour]
    }
    
    
    /*
      - via: Dots.updateViaPan
     */
   func nextHour(_ hourNext: Int) {
 
        if hourNext == hour {
            return
        }
        let deltaHour = hourNext - hour
        
        hour = hourNext
        // crossing midnight while going forward
        if deltaHour < -12  {
            
            if day <= days {
                day += 1
            }
        }
            // crossing midnight while going backward
        else if deltaHour > 12 {
            if day >= -days {
                day -= 1
            }
        }
              // spinning forward past end
        else if index < maxIndex-1 && index + deltaHour >= maxIndex-1 {
            Haptic.play(.click)
            hour = hour0 - 1
        }
            // spinning backward past beginning
        else if index > 1-maxIndex && index + deltaHour <= 1-maxIndex {
            Haptic.play(.click)
            hour = hour0 - 1
        }
        updateHourWeekDay()
        //print ("⌛︎ nextHour index(\(indexPrev) → \(index)) day(\(dayPrev) → \(day)) hour(\(hourPrev) → \(hour)) delta(\(deltaHour))")
    }
    /*
     /// - via: nextHour
     */
    func updateHourWeekDay() {
        
        hour = (hours + hour) % hours
        day = min(days,max(-days,day))
        weekday = (7 + weekday0 - 1 + day) % 7 // which day of week
        
        index = day * hours + (hour - hour0)
        
        if index < 1-maxIndex {
            if index > 1-maxIndex - 6 {
                index = 1-maxIndex
                hour = (hours + hour0 + 1) % hours
            }
            else {
                index += hours
                day   += 1
            }
        }
        else if index >= maxIndex {
            if index < maxIndex + 6 {
                index = maxIndex - 1
                hour = (hours + hour0 - 1) % hours
            }
            else {
                index -= hours
                day   -= 1
            }
        }
    }

}
