import Foundation

class TimeService: Service {
    private var timesCache = [NSDate: NSAttributedString]()
    
    func parseTime(time: NSDate) -> NSAttributedString {
        if let parsedTime = timesCache[time] {
            return parsedTime
        }
        
        timesCache[time] = JSQMessagesTimestampFormatter.sharedFormatter().attributedTimestampForDate(time)
        
        return timesCache[time]!
    }
}