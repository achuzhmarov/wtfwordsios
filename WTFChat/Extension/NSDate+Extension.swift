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
}