import Foundation

extension Date
{
    func isGreater(_ dateToCompare : Date) -> Bool
    {
        return self.compare(dateToCompare) == ComparisonResult.orderedDescending
    }
    
    func isLess(_ dateToCompare : Date) -> Bool
    {
        return self.compare(dateToCompare) == ComparisonResult.orderedAscending
    }
    
    static func defaultPast() -> Date {
        return Date().addYears(-1)
    }

    func addDays(_ daysToAdd : Int) -> Date
    {
        let calendar = Calendar.current
        return (calendar as NSCalendar).date(byAdding: .day, value: daysToAdd, to: self, options: NSCalendar.Options())!
    }
    
    func addYears(_ yearsToAdd : Int) -> Date
    {
        let calendar = Calendar.current

        //if #available(iOS 8.0, *) {
            return (calendar as NSCalendar).date(byAdding: .year, value: yearsToAdd, to: self, options: NSCalendar.Options())!
        /*} else {
            //approximation
            let secondsInYear : NSTimeInterval = Double(yearsToAdd) * 60 * 60 * 24 * 365
            return self.dateByAddingTimeInterval(secondsInYear)
        }*/
    }
    
    static func parseDateFromStringJSON(_ string: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
        return dateFormatter.date(from: string)
    }
    
    static func parseStringJSONFromDate(_ date: Date) -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
        return dateFormatter.string(from: date)
    }
    
    func getYear() -> Int {
        let calendar = Calendar.current
        return (calendar as NSCalendar).components(.year, from: self).year!
    }
    
    func getMonth() -> Int {
        let calendar = Calendar.current
        return (calendar as NSCalendar).components(.month, from: self).month!
    }
    
    func getDay() -> Int {
        let calendar = Calendar.current
        return (calendar as NSCalendar).components(.day, from: self).day!
    }

    func yearsFrom(_ date: Date) -> Int {
        return (Calendar.current as NSCalendar).components(.year, from: date, to: self, options: []).year!
    }

    func monthsFrom(_ date: Date) -> Int {
        return (Calendar.current as NSCalendar).components(.month, from: date, to: self, options: []).month!
    }

    func weeksFrom(_ date: Date) -> Int {
        return (Calendar.current as NSCalendar).components(.weekOfYear, from: date, to: self, options: []).weekOfYear!
    }

    func daysFrom(_ date: Date) -> Int {
        return (Calendar.current as NSCalendar).components(.day, from: date, to: self, options: []).day!
    }

    func hoursFrom(_ date: Date) -> Int {
        return (Calendar.current as NSCalendar).components(.hour, from: date, to: self, options: []).hour!
    }

    func minutesFrom(_ date: Date) -> Int{
        return (Calendar.current as NSCalendar).components(.minute, from: date, to: self, options: []).minute!
    }

    func secondsFrom(_ date: Date) -> Int{
        return (Calendar.current as NSCalendar).components(.second, from: date, to: self, options: []).second!
    }

    func offsetFrom(_ date: Date) -> String {
        if yearsFrom(date)   > 0 { return "\(yearsFrom(date))y"   }
        if monthsFrom(date)  > 0 { return "\(monthsFrom(date))M"  }
        if weeksFrom(date)   > 0 { return "\(weeksFrom(date))w"   }
        if daysFrom(date)    > 0 { return "\(daysFrom(date))d"    }
        if hoursFrom(date)   > 0 { return "\(hoursFrom(date))h"   }
        if minutesFrom(date) > 0 { return "\(minutesFrom(date))m" }
        if secondsFrom(date) > 0 { return "\(secondsFrom(date))s" }
        return ""
    }
}
