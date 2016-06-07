import Foundation

class JsonRemoteMessageParser {
    class func arrayFromJson(json: JSON) throws -> [RemoteMessage] {
        var messages = [RemoteMessage]()

        if let value = json.array {
            for messageJson in value {
                try messages.append(JsonRemoteMessageParser.fromJson(messageJson))
            }
        } else {
            throw json.error!
        }

        return messages
    }

    class func newFromMessage(message: RemoteMessage) -> JSON {
        var json: JSON = [
            "talk_id": message.talkId,
            "author": message.author,
            "deciphered": message.deciphered,
            "cipher_type": message.cipherType.rawValue,
            "cipher_difficulty": message.cipherDifficulty.rawValue,
            "timestamp": NSDate.parseStringJSONFromDate(message.timestamp)!,
            "last_update": NSDate.parseStringJSONFromDate(message.lastUpdate)!,
            "ext_id": message.extId,
        ]

        json["words"].arrayObject = JsonRemoteMessageParser.wordsFromMessage(message)


        return json
    }

    class func decipherFromMessage(message: RemoteMessage) -> JSON {
        var json: JSON = [
            "id": message.id,
            "timer_secs": message.timerSecs,
            "hints_used": message.hintsUsed
        ]

        json["words"].arrayObject = JsonRemoteMessageParser.wordsFromMessage(message)
        json["tries"].arrayObject = JsonRemoteMessageParser.triesFromMessage(message)

        return json
    }

    class func triesFromMessage(message: RemoteMessage) -> [AnyObject] {
        var triesJson = [AnyObject]()

        for i in 0..<message.tries.count {
            let tryJson = JSON(message.tries[i])
            triesJson.append(tryJson.rawValue)
        }

        return triesJson
    }

    class func wordsFromMessage(message: RemoteMessage) -> [AnyObject] {
        var wordsJson = [AnyObject]()

        for i in 0..<message.words!.count {
            let wordJson = JsonWordParser.fromWord(message.words![i])
            wordsJson.append(wordJson.rawValue)
        }

        return wordsJson
    }

    class func fromJson(json: JSON) throws -> RemoteMessage {
        var id: String
        var talkId: String
        var author: String
        var words = [Word]()
        var deciphered: Bool
        var cipherType: CipherType
        var cipherDifficulty: CipherDifficulty
        var timestamp: NSDate
        var lastUpdate: NSDate
        var exp: Int = 0
        var extId: String
        var timerSecs: Int = 0
        var hintsUsed: Int = 0

        if let value = json["id"].string {
            id = value
        } else {
            throw json["id"].error!
        }

        if let value = json["ext_id"].string {
            extId = value
        } else {
            throw json["ext_id"].error!
        }

        if let value = json["talk_id"].string {
            talkId = value
        } else {
            throw json["talk_id"].error!
        }

        if let value = json["author"].string {
            author = value
        } else {
            throw json["author"].error!
        }

        if let value = json["deciphered"].bool {
            deciphered = value
        } else {
            throw json["deciphered"].error!
        }

        if let value = json["cipher_type"].int {
            cipherType = CipherType(rawValue: value)!
        } else {
            throw json["cipher_type"].error!
        }

        if let value = json["cipher_difficulty"].int {
            cipherDifficulty = CipherDifficulty(rawValue: value)!
        } else {
            throw json["cipher_difficulty"].error!
        }

        if let value = json["timestamp"].string {
            if let parsedTimestamp = NSDate.parseDateFromStringJSON(value) {
                timestamp = parsedTimestamp
            } else {
                throw NSError(code: 1, message: "Could not parse timestamp")
            }
        } else {
            throw json["timestamp"].error!
        }

        if let value = json["last_update"].string {
            if let parsedTimestamp = NSDate.parseDateFromStringJSON(value) {
                lastUpdate = parsedTimestamp
            } else {
                lastUpdate = timestamp
                //throw NSError(code: 1, message: "Could not parse lastUpdate")
            }
        } else {
            lastUpdate = timestamp
            //throw json["last_update"].error!
        }

        if let value = json["words"].array {
            for wordJson in value {
                try words.append(JsonWordParser.fromJson(wordJson))
            }
        } else {
            throw json["words"].error!
        }

        if let value = json["exp"].int {
            exp = value
        } else if let error = json["exp"].error {
            throw error
        }

        if let value = json["timer_secs"].int {
            timerSecs = value
        } else if let error = json["timer_secs"].error {
            throw error
        }

        if let value = json["hints_used"].int {
            hintsUsed = value
        } else if let error = json["hints_used"].error {
            throw error
        }

        return RemoteMessage(
            id: id,
            talkId: talkId,
            author: author,
            words: words,
            deciphered: deciphered,
            cipherType: cipherType,
            cipherDifficulty: cipherDifficulty,
            timestamp: timestamp,
            lastUpdate: lastUpdate,
            exp: exp,
            extId: extId,
            timerSecs: timerSecs,
            hintsUsed: hintsUsed
        )
    }
}
