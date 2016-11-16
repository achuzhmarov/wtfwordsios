import Foundation

enum WordType: Int {
    case new = 1, success, failed, delimiter, ignore, lineBreak, closeTry
}

class Word: NSObject {
    static let HIDE_SYMBOL = "*"

    static let NOT_HIDED_SYMBOLS: [Character] = [".", ",", "!", "?", "(", ")", " ", "\n"]

    var text: String
    var type = WordType.new
    var additional = ""
    var fullCipheredText = ""

    var wasCloseTry = false

    init (word: Word) {
        self.text = word.text
        self.additional = word.additional
        self.type = word.type
        self.fullCipheredText = word.fullCipheredText
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

    init(text: String, additional: String, type: WordType, fullCipheredText: String) {
        self.text = text
        self.additional = additional
        self.type = type
        self.fullCipheredText = fullCipheredText
    }

    init(text: String, additional: String, type: WordType, fullCipheredText: String, wasCloseTry: Bool) {
        self.text = text
        self.additional = additional
        self.type = type
        self.fullCipheredText = fullCipheredText
        self.wasCloseTry = wasCloseTry
    }

    var cipheredText: String {
        var newWord = ""
        var isLastCharDot = false

        for i in 0 ..< fullCipheredText.characters.count {
            if (fullCipheredText[i] == ".") {
                if (isLastCharDot) {
                    //skip
                } else {
                    newWord = "\(newWord)..."
                }

                isLastCharDot = true
            } else {
                isLastCharDot = false
                newWord = "\(newWord)\(fullCipheredText[i])"
            }
        }

        return newWord + additional
    }

    func getClearText() -> String {
        return self.text + self.additional
    }

    func getHidedText() -> String {
        var result = ""

        var textToHide = ""

        if (cipheredText != "") {
            textToHide = cipheredText
                //.replace(".", with: "")
                .replace(additional, with: "")
        } else {
            textToHide = text
        }

        for char in textToHide.characters {
            result += getHidedChar(char)
        }

        for char in additional.characters {
            result += getHidedChar(char)
        }

        return result
    }

    func getHidedChar(_ char: Character) -> String {
        if (Word.NOT_HIDED_SYMBOLS.contains(char)) {
            return String(char)
        } else {
            return Word.HIDE_SYMBOL
        }
    }

    fileprivate func hasText() -> Bool {
        switch type {
        case .delimiter:
            return false
        case .lineBreak:
            return false
        case .ignore:
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
        return hasText() && type != .ignore
    }

    func getCipheredText() -> String {
        return cipheredText
    }

    func getTextForDecipher() -> String {
        if (self.type == WordType.new) {
            return cipheredText
        } else {
            return text + additional
        }
    }

    func getCharCount() -> Int {
        return text.characters.count
    }

    func getCapitalized() -> String {
        return text.capitalized
    }

    func getUpperCase() -> String {
        return text.uppercased()
    }

    func getLowerCase() -> String {
        return text.lowercased()
    }

    class func delimiterWord() -> Word {
        return Word(text: "", additional: " ", type: WordType.delimiter)
    }

    class func lineBreakWord() -> Word {
        return Word(text: "", additional: "\n", type: WordType.lineBreak)
    }

    func checkEquals(_ word: Word) -> Bool {
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
