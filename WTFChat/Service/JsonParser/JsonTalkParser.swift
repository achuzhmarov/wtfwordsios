import Foundation

class JsonTalkParser {
    class func arrayFromJson(json: JSON) throws -> [Talk] {
        var talks = [Talk]()

        if let value = json.array {
            for talkJson in value {
                try talks.append(JsonTalkParser.fromJson(talkJson))
            }
        } else {
            throw json.error!
        }

        return talks
    }

    class func fromJson(json: JSON) throws -> Talk {
        var id: String
        var hasUnread: Bool
        var cipheredNum: Int
        var lastMessage: RemoteMessage?
        var users = [String]()
        var decipherStatus: DecipherStatus
        var lastUpdate: NSDate
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
                decipherStatus = DecipherStatus.No
            } else {
                decipherStatus = DecipherStatus(rawValue: value)!
            }
        } else {
            decipherStatus = DecipherStatus.No
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
            if let parsedTimestamp = NSDate.parseDateFromStringJSON(value) {
                lastUpdate = parsedTimestamp
            } else {
                lastUpdate = NSDate()
                //throw NSError(code: 1, message: "Could not parse lastUpdate")
            }
        } else {
            lastUpdate = NSDate()
            //throw json["last_update"].error!
        }

        return Talk(
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
