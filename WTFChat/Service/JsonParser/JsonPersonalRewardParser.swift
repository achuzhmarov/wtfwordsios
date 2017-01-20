import Foundation
import SwiftyJSON

class JsonPersonalRewardParser {
    class func fromJson(_ json: JSON) throws -> PersonalReward {
        var hasReward: Bool
        var message: String
        var wtfs: Int

        if let value = json["hasReward"].bool {
            hasReward = value
        } else {
            throw json["hasReward"].error!
        }

        if let value = json["message"].string {
            message = value
        } else if let error = json["message"].error {
            throw error
        } else {
            message = ""
        }

        if let value = json["wtfs"].int {
            wtfs = value
        } else {
            throw json["wtfs"].error!
        }

        return PersonalReward(
                hasReward: hasReward,
                message: message,
                wtfs: wtfs
        )
    }
}
