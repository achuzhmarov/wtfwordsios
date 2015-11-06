//
//  TimeService.swift
//  WTFChat
//
//  Created by Artem Chuzhmarov on 05/11/15.
//  Copyright © 2015 Artem Chuzhmarov. All rights reserved.
//

import Foundation

let timeService = TimeService()

class TimeService {
    var timesCache = [NSDate: NSAttributedString]()
    
    func parseTime(time: NSDate) -> NSAttributedString {
        if let parsedTime = timesCache[time] {
            return parsedTime
        }
        
        timesCache[time] = JSQMessagesTimestampFormatter.sharedFormatter().attributedTimestampForDate(time)
        
        return timesCache[time]!
    }
}