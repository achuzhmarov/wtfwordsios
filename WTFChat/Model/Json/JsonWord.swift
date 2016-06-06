import Foundation

enum WordType: Int {
    case New = 1, Success, Failed, Delimiter, Ignore, LineBreak, CloseTry
}

class JsonWord : NSObject {
    var text: String
    var wordType = WordType.New
    var additional = ""
    var cipheredText = ""
    var wasCloseTry = false
    
    init (word: Word) {
        self.text = word.text
        self.additional = word.additional
        self.wordType = word.wordType
        self.cipheredText = word.cipheredText
        self.wasCloseTry = word.wasCloseTry
    }
    
    init(text: String) {
        self.text = text
    }
    
    init(text: String, wordType: WordType) {
        self.text = text
        self.wordType = wordType
    }

    init(text: String, additional: String) {
        self.text = text
        self.additional = additional
    }
    
    init(text: String, additional: String, wordType: WordType) {
        self.text = text
        self.additional = additional
        self.wordType = wordType
    }
    
    init(text: String, additional: String, wordType: WordType, cipheredText: String) {
        self.text = text
        self.additional = additional
        self.wordType = wordType
        self.cipheredText = cipheredText
    }
    
    init(text: String, additional: String, wordType: WordType, cipheredText: String, wasCloseTry: Bool) {
        self.text = text
        self.additional = additional
        self.wordType = wordType
        self.cipheredText = cipheredText
        self.wasCloseTry = wasCloseTry
    }
    
    func getJson() -> JSON {
        let json: JSON =  [
            "text": self.text,
            "additional": self.additional,
            "ciphered_text": self.cipheredText,
            "word_type": self.wordType.rawValue
        ]
        
        return json
    }
    
    class func parseFromJson(json: JSON) throws -> Word {
        var text: String
        var additional: String
        var cipheredText: String
        var wordType: WordType
        
        if let value = json["text"].string {
            text = value
        } else {
            throw json["text"].error!
        }
        
        if let value = json["additional"].string {
            additional = value
        } else {
            throw json["additional"].error!
        }
        
        if let value = json["ciphered_text"].string {
            cipheredText = value
        } else {
            throw json["ciphered_text"].error!
        }
        
        if let value = json["word_type"].int {
            wordType = WordType(rawValue: value)!
        } else {
            throw json["word_type"].error!
        }
        
        return Word(
            text: text,
            additional: additional,
            wordType: wordType,
            cipheredText: cipheredText
        )
    }
}