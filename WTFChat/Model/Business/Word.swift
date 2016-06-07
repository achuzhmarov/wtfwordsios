import Foundation

enum WordType: Int {
    case New = 1, Success, Failed, Delimiter, Ignore, LineBreak, CloseTry
}

class Word: NSObject {
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

    init(text: String, wordType: WordType) {
        self.text = text
        self.wordType = wordType
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
