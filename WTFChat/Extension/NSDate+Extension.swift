//
//  NSDate+Extensions.swift
//  WTFChat
//
//  Created by Artem Chuzhmarov on 12/01/16.
//  Copyright © 2016 Artem Chuzhmarov. All rights reserved.
//

import Foundation

extension NSDate
{
    func isGreater(dateToCompare : NSDate) -> Bool
    {
        return self.compare(dateToCompare) == NSComparisonResult.OrderedDescending
    }
    
    func isLess(dateToCompare : NSDate) -> Bool
    {
        return self.compare(dateToCompare) == NSComparisonResult.OrderedAscending
    }
    
    class func defaultPast() -> NSDate {
        return NSDate().addYears(-1)
    }
    
    func addYears(yearsToAdd : Int) -> NSDate
    {
        let calendar = NSCalendar.currentCalendar()

        //if #available(iOS 8.0, *) {
            return calendar.dateByAddingUnit(.Year, value: yearsToAdd, toDate: self, options: NSCalendarOptions())!
        /*} else {
            //approximation
            let secondsInYear : NSTimeInterval = Double(yearsToAdd) * 60 * 60 * 24 * 365
            return self.dateByAddingTimeInterval(secondsInYear)
        }*/
    }
    
    class func parseDateFromStringJSON(string: String) -> NSDate? {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
        return dateFormatter.dateFromString(string)
    }
    
    class func parseStringJSONFromDate(date: NSDate) -> String? {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
        return dateFormatter.stringFromDate(date)
    }
    
    func getYear() -> Int {
        let calendar = NSCalendar.currentCalendar()
        return calendar.components(.Year, fromDate: self).year
    }
    
    func getMonth() -> Int {
        let calendar = NSCalendar.currentCalendar()
        return calendar.components(.Month, fromDate: self).month
    }
    
    func getDay() -> Int {
        let calendar = NSCalendar.currentCalendar()
        return calendar.components(.Day, fromDate: self).day
    }

    func yearsFrom(date: NSDate) -> Int {
        return NSCalendar.currentCalendar().components(.Year, fromDate: date, toDate: self, options: []).year
    }

    func monthsFrom(date: NSDate) -> Int {
        return NSCalendar.currentCalendar().components(.Month, fromDate: date, toDate: self, options: []).month
    }

    func weeksFrom(date: NSDate) -> Int {
        return NSCalendar.currentCalendar().components(.WeekOfYear, fromDate: date, toDate: self, options: []).weekOfYear
    }

    func daysFrom(date: NSDate) -> Int {
        return NSCalendar.currentCalendar().components(.Day, fromDate: date, toDate: self, options: []).day
    }

    func hoursFrom(date: NSDate) -> Int {
        return NSCalendar.currentCalendar().components(.Hour, fromDate: date, toDate: self, options: []).hour
    }

    func minutesFrom(date: NSDate) -> Int{
        return NSCalendar.currentCalendar().components(.Minute, fromDate: date, toDate: self, options: []).minute
    }

    func secondsFrom(date: NSDate) -> Int{
        return NSCalendar.currentCalendar().components(.Second, fromDate: date, toDate: self, options: []).second
    }

    func offsetFrom(date: NSDate) -> String {
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