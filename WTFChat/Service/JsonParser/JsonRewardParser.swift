import Foundation
import SwiftyJSON

class JsonRewardParser {
    class func fromJson(_ json: JSON) throws -> Reward {
        var hasReward: Bool
        var message: String
        var wtfs: Int
        var isExpired: Bool = false;
        var isAlreadyClaimed: Bool = false;

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

        if let value = json["expired"].bool {
            isExpired = value
        } else {
            throw json["expired"].error!
        }

        if let value = json["alreadyClaimed"].bool {
            isAlreadyClaimed = value
        } else {
            throw json["alreadyClaimed"].error!
        }

        return Reward(
                hasReward: hasReward,
                message: message,
                wtfs: wtfs,
                isExpired: isExpired,
                isAlreadyClaimed: isAlreadyClaimed
        )
    }
}
