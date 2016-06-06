import Foundation

enum MessageStatus: Int {
    case Ciphered = 1, Success, Failed
}

class Message: JsonMessage {
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

    func guessIsNotStarted() -> Bool {
        return !deciphered && (timerSecs == 0)
    }

    func hasSuccessWords() -> Bool {
        let successWordsCount = countWordsByStatus(WordType.Success) + countWordsByStatus(WordType.CloseTry)
        return successWordsCount == 0
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
            if (word.wordType == wordType) {
                result += 1
            }
        }

        return result
    }

    func text() -> String {
        if (deciphered) {
            return clearText()
        } else {
            return questionMarks()
        }
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
}
