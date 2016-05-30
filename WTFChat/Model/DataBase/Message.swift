//
//  Message.swift
//  wttc
//
//  Created by Artem Chuzhmarov on 05/09/15.
//  Copyright (c) 2015 Artem Chuzhmarov. All rights reserved.
//

import Foundation

class Message : BaseEntity {
    let timestamp: NSDate
    let talkId: String
    
    var lastUpdate: NSDate
    var author: String
    var words: [Word]!
    var deciphered: Bool
    var cipherType = CipherType.HalfWordRoundDown
    var exp: Int = 0
    
    var isLocal: Bool = false
    var extId: String = ""
    
    var timerSecs: Int = 0
    var hintsUsed: Int = 0
    var tries = [String]()
    
    init(id: String, talkId: String, author: String) {
        
        self.timestamp = NSDate()
        self.lastUpdate = self.timestamp
        self.talkId = talkId
        self.author = author
        self.deciphered = false
        
        super.init(id: id)
    }
    
    init(id: String, talkId: String, author: String, words: [Word], cipherType: CipherType) {
        
        self.timestamp = NSDate()
        self.lastUpdate = self.timestamp
        self.talkId = talkId
        self.author = author
        self.deciphered = false
        self.cipherType = cipherType
        
        self.words = words
        
        super.init(id: id)
    }
    
    init(id: String, talkId: String, author: String, words: [Word], deciphered: Bool) {
        
        self.timestamp = NSDate()
        self.lastUpdate = self.timestamp
        self.talkId = talkId
        self.author = author
        self.deciphered = deciphered
        self.words = words
        
        super.init(id: id)
    }
    
    init(id: String, timestamp: NSDate, talkId: String, author: String, deciphered: Bool) {
        self.timestamp = timestamp
        self.lastUpdate = self.timestamp
        self.talkId = talkId
        self.author = author
        self.deciphered = deciphered
            
        super.init(id: id)
    }
    
    init(id: String, talkId: String, author: String, words: [Word], deciphered: Bool, cipherType: CipherType, timestamp: NSDate, lastUpdate: NSDate, exp: Int, extId: String, timerSecs: Int, hintsUsed: Int) {
        
        self.timestamp = timestamp
        self.lastUpdate = lastUpdate
        self.talkId = talkId
        self.author = author
        self.deciphered = deciphered
        self.cipherType = cipherType
        self.words = words
        self.exp = exp
        self.extId = extId
        self.timerSecs = timerSecs
        self.hintsUsed = hintsUsed
        
        super.init(id: id)
    }
    
    func cipherWords() {
        for word in words! {
            if (word.wordType == WordType.New) {
                word.cipheredText = CipherFactory.cipherText(cipherType, word: word)
            }
        }
    }
    
    func getWordsWithoutSpaces() -> [Word] {
        var result = [Word]()
        
        for word in words {
            if (word.wordType != WordType.Delimiter) {
                result.append(word)
            }
        }
        
        return result
    }
    
    func getWordsOnly() -> [Word] {
        var result = [Word]()
        
        for word in words {
            if (word.wordType != WordType.Delimiter &&
                word.wordType != WordType.LineBreak) {
                result.append(word)
            }
        }
        
        return result
    }

    func countSuccess() -> Int {
        return countWordsByStatus(WordType.Success) + countWordsByStatus(WordType.CloseTry)
    }
    
    func countNew() -> Int {
        return countWordsByStatus(WordType.New)
    }
    
    func countFailed() -> Int {
        return countWordsByStatus(WordType.Failed)
    }
    
    func countWordsByStatus(wordType: WordType) -> Int {
        var result = 0
        
        for word in words {
            if (word.wordType == wordType) {
                result += 1
            }
        }
        
        return result
    }
    
    func questionMarks() -> String! {
        var result = ""
        
        for word in words {
            if (word.wordType == WordType.Delimiter) {
                result = "\(result) "
            } else if (word.wordType == WordType.LineBreak) {
                result = "\(result)\n"
            } else if (word.wordType == WordType.Ignore) {
                if (word.text.characters.count > 0) {
                    result = "\(result)???\(word.additional)"
                } else {
                    result = "\(result)\(word.additional)"
                }
            } else {
                result = "\(result)???\(word.additional)"
            }
        }
        
        return result
    }
    
    func clearText() -> String! {
        var result = ""
        
        for word in words! {
            result = "\(result)\(word.getClearText())"
        }
            
        return result
    }
    
    func checkEquals(message: Message) -> Bool {
        if (self.words.count != message.words.count) {
            return false
        }
        
        for i in 0..<self.words.count {
            if (!self.words[i].checkEquals(message.words[i])) {
                return false
            }
        }
        
        return true
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
            timestamp: timestamp,
            lastUpdate: lastUpdate,
            exp: exp,
            extId: extId,
            timerSecs: timerSecs,
            hintsUsed: hintsUsed
        )
    }
}