import Foundation

class WTFTimer {
    var seconds = 0
    
    init() {}
    
    init(seconds: Int) {
        self.seconds = seconds
    }
    
    func tick() -> Bool {
        if (self.seconds >= 0) {
            self.seconds -= 1
        }
        
        return isFinished()
    }
    
    func isFinished() -> Bool {
        if (self.seconds < 0) {
            return true
        } else {
            return false
        }
    }
    
    func isLastSecond() -> Bool {
        if (self.seconds == 0) {
            return true
        } else {
            return false
        }
    }
    
    func isRunningOfTime() -> Bool {
        if (self.seconds == 10) {
            return true
        } else {
            return false
        }
    }
    
    func getMinutes() -> Int {
        return seconds / 60
    }
    
    func getSeconds() -> Int {
        return seconds % 60
    }
    
    func getTimeString() -> String {
        return "\(String(format: "%02d", getMinutes())):\(String(format: "%02d", getSeconds()))"
    }
}
