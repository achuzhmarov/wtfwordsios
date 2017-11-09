import Foundation

class WTFTimer {
    private var innerTimer: Timer?
    var seconds = 0

    var tickComputer: (() -> ())?

    init() {}

    init(seconds: Int, tickComputer: (() -> ())? = nil) {
        self.seconds = seconds
        self.tickComputer = tickComputer
    }

    func scheduleForOneSecond() {
        innerTimer?.invalidate()
        innerTimer = Timer.scheduledTimer(timeInterval: 1.0,
                target: self,
                selector: #selector(self.tick),
                userInfo: nil,
                repeats: false)

        RunLoop.main.add(innerTimer!, forMode: RunLoopMode.commonModes)
    }

    @objc func tick() {
        //call external method
        tickComputer?()
    }
    
    func secondPassed() -> Bool {
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
