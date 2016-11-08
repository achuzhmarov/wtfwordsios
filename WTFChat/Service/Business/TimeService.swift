import Foundation

class TimeService: Service {
    fileprivate var timesCache = [Date: NSAttributedString]()
    
    func parseTime(_ time: Date) -> NSAttributedString {
        if let parsedTime = timesCache[time] {
            return parsedTime
        }
        
        timesCache[time] = JSQMessagesTimestampFormatter.shared().attributedTimestamp(for: time)
        
        return timesCache[time]!
    }
}
