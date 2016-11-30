import Foundation
import SwiftyJSON

class JsonUserParser {
    class func friendsFromJson(_ json: JSON) throws -> [FriendInfo] {
        var friends = [FriendInfo]()

        if let value = json.array {
            for friendJson in value {
                try friends.append(JsonFriendInfoParser.fromJson(friendJson))
            }
        } else {
            throw json.error!
        }

        return friends
    }

    class func fromJson(_ json: JSON) throws -> User {
        var login: String
        var wtfs: Int = 0
        var talks = [FriendTalk]()
        var lastUpdate: Date = Date.defaultPast()
        var exp: Int = 0
        var singleExp: Int = 0
        var friends = [FriendInfo]()

        var name: String
        var pushNew: Bool = true
        var pushDeciphered: Bool = true

        var rating: Int = 0

        var adWtfsGained: Int = 0

        if let value = json["login"].string {
            login = value
        } else {
            throw json["login"].error!
        }

        if let value = json["wtfs"].int {
            wtfs = value
        } else if let error = json["wtfs"].error {
            throw error
        }

        if let value = json["talks"].array {
            for talkJson in value {
                try talks.append(JsonTalkParser.fromJson(talkJson))
            }
        } else if (json["talks"].isEmpty) {
            //do nothing
        } else if let error = json["talks"].error {
            throw error
        }

        if let value = json["last_update"].string {
            if let parsedTimestamp = Date.parseDateFromStringJSON(value) {
                lastUpdate = parsedTimestamp
            } else {
                //throw NSError(code: 1, message: "Could not parse lastUpdate")
            }
        } else {
            //throw error
        }

        if let value = json["exp"].int {
            exp = value
        } else if let error = json["exp"].error {
            throw error
        }

        if let value = json["single_exp"].int {
            singleExp = value
        } else if let error = json["single_exp"].error {
            throw error
        }

        if let value = json["friends_lvls"].array {
            for friendJson in value {
                try friends.append(JsonFriendInfoParser.fromJson(friendJson))
            }
        } else if let error = json["friends_lvls"].error {
            throw error
        }

        if let value = json["name"].string {
            name = value
        } else {
            throw json["name"].error!
        }

        if let value = json["push_new"].bool {
            pushNew = value
        } else {
            //do nothing
            //throw json["has_unread"].error!
        }

        if let value = json["push_deciphered"].bool {
            pushDeciphered = value
        } else {
            //do nothing
            //throw json["has_unread"].error!
        }

        if let value = json["rating"].int {
            rating = value
        } else if let error = json["rating"].error {
            throw error
        }

        if let value = json["ad_wtfs_gained"].int {
            adWtfsGained = value
        } else if let error = json["ad_wtfs_gained"].error {
            throw error
        }

        return User(
            login: login,
            wtfs: wtfs,
            talks: talks,
            lastUpdate: lastUpdate,
            exp: exp,
            singleExp: singleExp,
            friends: friends,
            name: name,
            pushNew: pushNew,
            pushDeciphered: pushDeciphered,
            rating: rating,
            adWtfsGained: adWtfsGained
        )
    }
}
