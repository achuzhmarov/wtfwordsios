import Foundation

class Reward: NSObject {
    var hasReward: Bool = false
    var message: String = ""
    var wtfs: Int = 0
    var isExpired: Bool = false;
    var isAlreadyClaimed: Bool = false;

    init(hasReward: Bool, message: String, wtfs: Int, isExpired: Bool, isAlreadyClaimed: Bool) {
        self.hasReward = hasReward
        self.message = message
        self.wtfs = wtfs
        self.isExpired = isExpired
        self.isAlreadyClaimed = isAlreadyClaimed
    }
}
