import Foundation

enum MessageStatus: Int {
    case Ciphered = 1, Success, Failed
}

class Message: NSObject {
    var timestamp: NSDate
    var lastUpdate: NSDate
    var cipherType = CipherType.RightCutter
    var cipherDifficulty = CipherDifficulty.Normal

    var extId: String = ""
    var deciphered: Bool = false
    var exp: Int = 0
    var timerSecs: Int = 0
    var hintsUsed: Int = 0

    var words: [Word]!
    var tries = [String]()

    override init() {
        self.timestamp = NSDate()
        self.lastUpdate = timestamp
    }

    init(extId: String, cipherType: CipherType, cipherDifficulty: CipherDifficulty, words: [Word]) {
        self.extId = extId
        self.cipherType = cipherType
        self.cipherDifficulty = cipherDifficulty
        self.words = words

        self.timestamp = NSDate()
        self.lastUpdate = timestamp
    }

    init(extId: String, cipherType: CipherType, cipherDifficulty: CipherDifficulty, words: [Word],
         deciphered: Bool, timestamp: NSDate, lastUpdate: NSDate, exp: Int, timerSecs: Int, hintsUsed: Int) {

        self.extId = extId
        self.cipherType = cipherType
        self.cipherDifficulty = cipherDifficulty
        self.words = words

        self.deciphered = deciphered
        self.timestamp = timestamp
        self.lastUpdate = lastUpdate
        self.exp = exp
        self.timerSecs = timerSecs
        self.hintsUsed = hintsUsed
    }

    func getWordsWithoutSpaces() -> [Word] {
        var result = [Word]()

        for word in words {
            if (word.type != WordType.Delimiter) {
                result.append(word)
            }
        }

        return result
    }

    func getWordsOnly() -> [Word] {
        var result = [Word]()

        for word in words {
            if (word.type != WordType.Delimiter &&
                    word.type != WordType.LineBreak) {
                result.append(word)
            }
        }

        return result
    }

    func guessIsNotStarted() -> Bool {
        return !deciphered && (timerSecs == 0)
    }

    func hasSuccessWords() -> Bool {
        let successWordsCount = countWordsByStatus(WordType.Success) + countWordsByStatus(WordType.CloseTry)
        return successWordsCount > 0
    }

    func countNew() -> Int {
        return countWordsByStatus(WordType.New)
    }

    func getMessageStatus() -> MessageStatus {
        if (deciphered) {
            if (countWordsByStatus(WordType.Failed) == 0) {
                return MessageStatus.Success
            } else {
                return MessageStatus.Failed
            }
        } else {
            return MessageStatus.Ciphered
        }

    }

    private func countWordsByStatus(wordType: WordType) -> Int {
        var result = 0

        for word in words {
            if (word.type == wordType) {
                result += 1
            }
        }

        return result
    }

    func text() -> String {
        if (deciphered) {
            return clearText()
        } else {
            return getHidedText()
        }
    }

    func ciphered() -> String {
        var result = ""

        for word: Word in words {
            result += word.getTextForDecipher()
        }

        return result
    }

    func getHidedText() -> String! {
        var result = ""

        for word: Word in words {
            result += word.getHidedText()
        }

        return result
    }

    func clearText() -> String! {
        var result = ""

        for word: Word in words! {
            result += word.getClearText()
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
}
