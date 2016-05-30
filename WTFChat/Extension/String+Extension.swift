//
//  String+Extension.swift
//  WTFChat
//
//  Created by Artem Chuzhmarov on 12/01/16.
//  Copyright © 2016 Artem Chuzhmarov. All rights reserved.
//

import Foundation

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
    
    subscript (i: Int) -> String {
        let char = self[self.startIndex.advancedBy(i)]
        return String(char)
    }
    
    subscript (r: Range<Int>) -> String {
        return substringWithRange(startIndex.advancedBy(r.startIndex)..<startIndex.advancedBy(r.endIndex))
    }
    
    var shuffle:String {
        return String(Array(self.characters).shuffle)
    }
}