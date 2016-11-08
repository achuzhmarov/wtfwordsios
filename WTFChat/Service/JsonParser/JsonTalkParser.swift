import Foundation
import SwiftyJSON

class JsonTalkParser {
    class func arrayFromJson(_ json: JSON) throws -> [FriendTalk] {
        var talks = [FriendTalk]()

        if let value = json.array {
            for talkJson in value {
                try talks.append(JsonTalkParser.fromJson(talkJson))
            }
        } else {
            throw json.error!
        }

        return talks
    }

    class func fromJson(_ json: JSON) throws -> FriendTalk {
        var id: String
        var hasUnread: Bool
        var cipheredNum: Int
        var lastMessage: RemoteMessage?
        var users = [String]()
        var decipherStatus: DecipherStatus
        var lastUpdate: Date
        var messageCount: Int

        if let value = json["id"].string {
            id = value
        } else {
            throw json["id"].error!
        }

        if let value = json["users"].array {
            for userJson in value {
                if let user = userJson.string {
                    users.append(user)
                } else {
                    throw userJson.error!
                }
            }
        } else {
            throw json["users"].error!
        }

        if let value = json["has_unread"].bool {
            hasUnread = value
        } else {
            throw json["has_unread"].error!
        }

        if let value = json["has_deciphered"].int {
            if (value == 0) {
                decipherStatus = DecipherStatus.no
            } else {
                decipherStatus = DecipherStatus(rawValue: value)!
            }
        } else {
            decipherStatus = DecipherStatus.no
            //throw json["has_deciphered"].error!
        }

        if let value = json["ciphered_num"].int {
            cipheredNum = value
        } else {
            throw json["ciphered_num"].error!
        }

        if let value = json["message_count"].int {
            messageCount = value
        } else {
            throw json["message_count"].error!
        }

        if json["last_message"].null == nil {
            lastMessage = try JsonRemoteMessageParser.fromJson(json["last_message"])
        }

        if let value = json["last_update"].string {
            if let parsedTimestamp = Date.parseDateFromStringJSON(value) {
                lastUpdate = parsedTimestamp
            } else {
                lastUpdate = Date()
                //throw NSError(code: 1, message: "Could not parse lastUpdate")
            }
        } else {
            lastUpdate = Date()
            //throw json["last_update"].error!
        }

        return FriendTalk(
            id: id,
            hasUnread: hasUnread,
            cipheredNum: cipheredNum,
            lastMessage: lastMessage,
            users: users,
            decipherStatus: decipherStatus,
            lastUpdate: lastUpdate,
            messageCount: messageCount
        )
    }
}
