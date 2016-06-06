import Foundation

class Word: JsonWord {
    func getClearText() -> String {
        return self.text + self.additional
    }

    func getCipheredText() -> String {
        return cipheredText
    }

    func getTextForDecipher() -> String {
        if (self.wordType == WordType.New) {
            return cipheredText
        } else {
            return text + additional
        }
    }

    func getCharCount() -> Int {
        return text.characters.count
    }

    func getCapitalized() -> String {
        return text.capitalizedString
    }

    func getUpperCase() -> String {
        return text.uppercaseString
    }

    func getLowerCase() -> String {
        return text.lowercaseString
    }

    class func delimiterWord() -> Word {
        return Word(text: " ", wordType: WordType.Delimiter)
    }

    class func lineBreakWord() -> Word {
        return Word(text: "\n", wordType: WordType.LineBreak)
    }

    func checkEquals(word: Word) -> Bool {
        if (self.wordType != word.wordType ||
                self.cipheredText != word.cipheredText ||
                self.text != word.text ||
                self.additional != word.additional
        )
        {
            return false
        } else {
            return true
        }
    }
}
