import Foundation

class JsonMessage : NSObject {
    let id: String

    let timestamp: NSDate
    let talkId: String
    
    var lastUpdate: NSDate
    var author: String
    var words: [Word]!
    var deciphered: Bool
    var cipherType = CipherType.RightCutter
    var cipherDifficulty = CipherDifficulty.Normal
    var exp: Int = 0
    
    var isLocal: Bool = false
    var extId: String = ""
    
    var timerSecs: Int = 0
    var hintsUsed: Int = 0
    var tries = [String]()
    
    init(id: String, talkId: String, author: String) {
        self.id = id;
        self.timestamp = NSDate()
        self.lastUpdate = self.timestamp
        self.talkId = talkId
        self.author = author
        self.deciphered = false
    }
    
    init(id: String, talkId: String, author: String, words: [Word], cipherType: CipherType, cipherDifficulty: CipherDifficulty) {
        self.id = id;
        self.timestamp = NSDate()
        self.lastUpdate = self.timestamp
        self.talkId = talkId
        self.author = author
        self.deciphered = false
        self.cipherType = cipherType
        self.cipherDifficulty = cipherDifficulty
        
        self.words = words
    }
    
    init(id: String, talkId: String, author: String, words: [Word], deciphered: Bool) {
        self.id = id;
        self.timestamp = NSDate()
        self.lastUpdate = self.timestamp
        self.talkId = talkId
        self.author = author
        self.deciphered = deciphered
        self.words = words
    }
    
    init(id: String, timestamp: NSDate, talkId: String, author: String, deciphered: Bool) {
        self.id = id;
        self.timestamp = timestamp
        self.lastUpdate = self.timestamp
        self.talkId = talkId
        self.author = author
        self.deciphered = deciphered
    }
    
    init(id: String, talkId: String, author: String, words: [Word], deciphered: Bool, cipherType: CipherType, cipherDifficulty: CipherDifficulty, timestamp: NSDate, lastUpdate: NSDate, exp: Int, extId: String, timerSecs: Int, hintsUsed: Int) {
        self.id = id;
        self.timestamp = timestamp
        self.lastUpdate = lastUpdate
        self.talkId = talkId
        self.author = author
        self.deciphered = deciphered
        self.cipherType = cipherType
        self.cipherDifficulty = cipherDifficulty
        self.words = words
        self.exp = exp
        self.extId = extId
        self.timerSecs = timerSecs
        self.hintsUsed = hintsUsed
    }
    
    class func parseArrayFromJson(json: JSON) throws -> [Message] {
        var messages = [Message]()
        
        if let value = json.array {
            for messageJson in value {
                try messages.append(Message.parseFromJson(messageJson))
            }
        } else {
            throw json.error!
        }
        
        return messages
    }
    
    func getNewJson() -> JSON {
        var json: JSON = [
            "talk_id": self.talkId,
            "author": self.author,
            "deciphered": self.deciphered,
            "cipher_type": self.cipherType.rawValue,
            "cipher_difficulty": self.cipherDifficulty.rawValue,
            "timestamp": NSDate.parseStringJSONFromDate(self.timestamp)!,
            "last_update": NSDate.parseStringJSONFromDate(self.lastUpdate)!,
            "ext_id": self.extId,
        ]
        
        json["words"].arrayObject = getWordsJson()
        
        
        return json
    }
    
    func getDecipherJson() -> JSON {
        var json: JSON = [
            "id": self.id,
            "timer_secs": self.timerSecs,
            "hints_used": self.hintsUsed
        ]
        
        json["words"].arrayObject = getWordsJson()
        json["tries"].arrayObject = getTriesJson()
        
        return json
    }
    
    func getTriesJson() -> [AnyObject] {
        var triesJson = [AnyObject]()
        
        for i in 0..<self.tries.count {
            let tryJson = JSON(tries[i])
            triesJson.append(tryJson.rawValue)
        }
        
        return triesJson
    }
    
    func getWordsJson() -> [AnyObject] {
        var wordsJson = [AnyObject]()
        
        for i in 0..<self.words!.count {
            let wordJson = self.words![i].getJson()
            wordsJson.append(wordJson.rawValue)
        }
        
        return wordsJson
    }
    
    class func parseFromJson(json: JSON) throws -> Message {
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
                try words.append(Word.parseFromJson(wordJson))
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

        return Message(
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