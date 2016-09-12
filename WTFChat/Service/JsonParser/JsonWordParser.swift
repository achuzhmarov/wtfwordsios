import Foundation
import SwiftyJSON

class JsonWordParser {
    class func fromWord(word: Word) -> JSON {
        let json: JSON =  [
                "text": word.text,
                "additional": word.additional,
                "ciphered_text": word.cipheredText,
                "word_type": word.type.rawValue
        ]

        return json
    }

    class func fromJson(json: JSON) throws -> Word {
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
            type: wordType,
            cipheredText: cipheredText
        )
    }
}
