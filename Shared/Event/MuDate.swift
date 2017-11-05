
import Foundation


open class MuDate {

    /// date as hh:mm:ss
    class func getHourMinSec (_ date: Date = Date()) -> String  {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm:ss"
        return dateFormatter.string(from:date)
    }

    /// date as hh:mm:ss.tttt
    class func getHourMinSecMsec (_ date: Date = Date()) -> String  {

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm:ss"
        let hourMinSec = dateFormatter.string(from:date)
        let msec = String(format:"%4.3f",modf(date.timeIntervalSince1970).1).substring(from: 1)
        return "\(hourMinSec)\(msec)"
    }

    /// return top of hour relative for current hour
    class func relativeHour(_ index: Int) -> Date {

        let cal = Calendar.current as NSCalendar
        //let nsdate = Date(timeIntervalSince1970:TimeInterval(timesec))

        let comps = (cal as NSCalendar).components([.year, .month, .day, .hour, .timeZone], from: Date())
        let hourNow = cal.date(from: comps) // trimmed off minutes no minutes
        let newDate = cal.date(byAdding: [.hour], value:index, to:hourNow!, options: NSCalendar.Options.matchNextTime)
        //let newTime = (newDate?.timeIntervalSince1970)!
        return newDate!
    }


    /// return top of hour relative for current hour
    class func relativeMinute(_ index: Int) -> Date {

        let cal = Calendar.current as NSCalendar

        let comps = (cal as NSCalendar).components([.year, .month, .day, .hour, .minute, .timeZone], from: Date())
        let minuteNow = cal.date(from: comps) // trimmed off minutes no minutes
        let newDate = cal.date(byAdding: [.minute], value:index, to:minuteNow!, options: NSCalendar.Options.matchNextTime)
        
        return newDate!
    }

    /// Beginning of day starting from days from now
    class func startOfDay(_ daysFromNow: Int) -> Int64 {
        
        let cal = Calendar.current as NSCalendar
        let startDate = cal.date(byAdding: [.day], value:daysFromNow, to: Date(), options: NSCalendar.Options.matchNextTime)
        let startMidnight = cal.date(bySettingHour: 0, minute: 0, second: 0, of:startDate!, options: NSCalendar.Options.matchNextTime)
        let newTime = Int64((startMidnight?.timeIntervalSince1970)!)
        return newTime
    }
    /// date with lowercase a p for am pm
    class func dateToString(_ startTime:TimeInterval, _ format: String) -> String {
        
        let formatter = DateFormatter()
        formatter.dateFormat = format
        formatter.amSymbol = "a"
        formatter.pmSymbol = "p"
        //formatter.timeZone = timezone
        let date = Date.init(timeIntervalSince1970: startTime)
        let result = formatter.string(from: date)
        return result;
    }
    
    class func dateToDateComp(_ nsdate: Date) -> DateComponents {
        
        let cal = Calendar.current
        return (cal as NSCalendar).components([.year, .month, .day, .hour, .minute, .second, .weekday, .timeZone], from: nsdate)
    }

    /**
     Elapsed time in either days, hours, or minutes
     where the cut of is at 1.5x the unit of, so:

     - 2 ...  7 days
     - 2 ... 36 hours
     - 0 ... 90 minutes
     */
    class func elapseTime(_ bgnTime: TimeInterval) -> String {
        
        let minSecs     = TimeInterval(60)
        let hourSecs    = TimeInterval(60*60)
        let daySecs     = TimeInterval(24*60*60)
        
        let currentTime = Date().timeIntervalSince1970
        let deltaTime   = abs(bgnTime - currentTime)
        var pre = ""
        var suf = ""
        
        if deltaTime > 1.5 * daySecs {
            pre = String(format:"%.f", deltaTime / daySecs)
            suf = "day"
        }
        else if deltaTime > 1.5 * hourSecs {
            pre = String(format:"%.f", deltaTime / hourSecs)
            suf = "hour"
        }
        else {
            pre = String(format:"%.f", deltaTime / minSecs)
            suf = "minute"
        }
        if pre != "1" {
            suf += "s"
        }
       return pre + " " + suf
    }

    class func secs2Comps(_ timesec:Int64) -> DateComponents {
        let nsdate = Date(timeIntervalSince1970:TimeInterval(timesec))
        return dateToDateComp(nsdate)
    }

    class func prevNextWeek() -> (Date?,Date?) {

        let cal = Calendar.current as NSCalendar
        let comps = Calendar.current.dateComponents([.year, .month, .day, .hour, .timeZone], from:Date())
        let nowDate = cal.date(from: comps)
        let bgnDate = cal.date(byAdding:.day, value:-7, to:nowDate!)
        let endDate = cal.date(byAdding:.day, value:7, to:nowDate!)
        return (bgnDate,endDate)
        
    }
}

