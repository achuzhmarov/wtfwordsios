//
//  Extensions.swift
//  WTFChat
//
//  Created by Artem Chuzhmarov on 07/09/15.
//  Copyright (c) 2015 Artem Chuzhmarov. All rights reserved.
//

import Foundation

func connectionErrorDescription() -> String {
    return "Internet connection problem"
}

infix operator ^^ { }
func ^^ (radix: Int, power: Int) -> Int {
    return Int(pow(Double(radix), Double(power)))
}

func isValidEmail(testStr:String) -> Bool {
    let emailRegEx = "^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$"
    
    let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
    return emailTest.evaluateWithObject(testStr)
}

func configureTitleView(title: String, navigationItem: UINavigationItem) {
    //let titleLabel = UILabel(frame: self.navigationController!.navigationBar.frame)
    let titleLabel = UILabel()
    titleLabel.textAlignment = .Center
    titleLabel.font = UIFont.boldSystemFontOfSize(17.0)
    titleLabel.text = title
    navigationItem.titleView = titleLabel
    titleLabel.sizeToFit()
    titleLabel.adjustsFontSizeToFitWidth = true
}

extension String
{
    func escapeForUrl() -> String? {
        return stringByAddingPercentEncodingWithAllowedCharacters(.URLHostAllowedCharacterSet())
    }
    
    func isGreater(stringToCompare : String) -> Bool
    {
        return self.compare(stringToCompare) == NSComparisonResult.OrderedDescending
    }
    
    func isLess(stringToCompare : String) -> Bool
    {
        return self.compare(stringToCompare) == NSComparisonResult.OrderedAscending
    }
}

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
}

extension NSDate
{
    class func defaultPast() -> NSDate {
        return NSDate().addYears(-1)
    }
    
    func addYears(yearsToAdd : Int) -> NSDate
    {
        let calendar = NSCalendar.currentCalendar()

        if #available(iOS 8.0, *) {
            return calendar.dateByAddingUnit(.Year, value: yearsToAdd, toDate: self, options: NSCalendarOptions())!
        } else {
            //approximation
            let secondsInYear : NSTimeInterval = Double(yearsToAdd) * 60 * 60 * 24 * 365
            return self.dateByAddingTimeInterval(secondsInYear)
        }
    }
}

extension NSDate {
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

extension NSError {
    convenience init(code: Int, message: String) {
        self.init(domain:"com.artemchuzhmarov", code: code, userInfo:[NSLocalizedDescriptionKey : message])
    }
}

extension String {
    func removeChars(chars: [String]) -> String {
        var result = self
        
        for char in chars {
            result = result.stringByReplacingOccurrencesOfString(char, withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
        }
        
        return result
    }
    
    func replace(what: String, with: String) -> String {
        return self.stringByReplacingOccurrencesOfString(what, withString: with, options: NSStringCompareOptions.LiteralSearch, range: nil)
    }
    
    /*subscript (i: Int) -> Character {
        return self[self.startIndex.advancedBy(i)]
    }*/
    
    subscript (i: Int) -> String {
        let char = self[self.startIndex.advancedBy(i)]
        return String(char)
    }
    
    subscript (r: Range<Int>) -> String {
        return substringWithRange(Range(start: startIndex.advancedBy(r.startIndex), end: startIndex.advancedBy(r.endIndex)))
    }
}

extension Array {
    var shuffle:[Element] {
        var elements = self
        for index in 0..<elements.count {
            let changeIndex = Int(arc4random_uniform(UInt32(elements.count-index)))+index
            
            if (index != changeIndex) {
                swap(&elements[index], &elements[changeIndex])
            }
        }
        return elements
    }
    var chooseOne: Element {
        return self[Int(arc4random_uniform(UInt32(count)))]
    }
    
}

extension String {
    var shuffle:String {
        return String(Array(self.characters).shuffle)
    }
}

extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(netHex:Int) {
        self.init(red:(netHex >> 16) & 0xff, green:(netHex >> 8) & 0xff, blue:netHex & 0xff)
    }
}

class Weak<T: AnyObject> {
    weak var value : T?
    init (value: T) {
        self.value = value
    }
}