import Foundation

enum WordType: Int {
    case New = 1, Success, Failed, Delimiter, Ignore, LineBreak, CloseTry
}

class Word: NSObject {
    static let HIDED_SYMBOL = "*"

    var text: String
    var type = WordType.New
    var additional = ""
    var cipheredText = ""
    var wasCloseTry = false

    init (word: Word) {
        self.text = word.text
        self.additional = word.additional
        self.type = word.type
        self.cipheredText = word.cipheredText
        self.wasCloseTry = word.wasCloseTry
    }

    init(text: String, type: WordType) {
        self.text = text
        self.type = type
    }

    init(text: String, additional: String, type: WordType) {
        self.text = text
        self.additional = additional
        self.type = type
    }

    init(text: String, additional: String, type: WordType, cipheredText: String) {
        self.text = text
        self.additional = additional
        self.type = type
        self.cipheredText = cipheredText
    }

    init(text: String, additional: String, type: WordType, cipheredText: String, wasCloseTry: Bool) {
        self.text = text
        self.additional = additional
        self.type = type
        self.cipheredText = cipheredText
        self.wasCloseTry = wasCloseTry
    }

    func getClearText() -> String {
        return self.text + self.additional
    }

    func getHidedText() -> String {
        var result = ""

        let cipheredTextOnly = cipheredText
            .replace(".", with: "")
            .replace(additional, with: "")

        for _ in 0..<cipheredTextOnly.characters.count {
            result += Word.HIDED_SYMBOL
        }

        return result + additional
    }

    private func hasText() -> Bool {
        switch type {
        case .Delimiter:
            return false
        case .LineBreak:
            return false
        case .Ignore:
            if (getCharCount() > 0) {
                return true
            } else {
                return false
            }
        default:
            return true
        }
    }

    func hasCipheredText() -> Bool {
        return hasText() && type != .Ignore
    }

    func getCipheredText() -> String {
        return cipheredText
    }

    func getTextForDecipher() -> String {
        if (self.type == WordType.New) {
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
        return Word(text: "", additional: " ", type: WordType.Delimiter)
    }

    class func lineBreakWord() -> Word {
        return Word(text: "", additional: "\n", type: WordType.LineBreak)
    }

    func checkEquals(word: Word) -> Bool {
        if (self.type != word.type ||
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