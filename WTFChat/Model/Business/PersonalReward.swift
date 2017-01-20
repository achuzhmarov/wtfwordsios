import Foundation

class PersonalReward: NSObject {
    var hasReward: Bool = false
    var message: String = ""
    var wtfs: Int = 0

    init(hasReward: Bool, message: String, wtfs: Int) {
        self.hasReward = hasReward
        self.message = message
        self.wtfs = wtfs
    }
}
