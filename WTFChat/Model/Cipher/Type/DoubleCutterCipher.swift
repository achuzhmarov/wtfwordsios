import Foundation

class DoubleCutterEasyCipher: Cipher {
    func getTextForDecipher(_ word: Word) -> String {
        if (word.getCharCount() == 2) {
            return DoubleCutterHelper.replaceFirstNonDot(word.getLowerCase())
        }

        let maxChars = word.getCharCount() / 2 + word.getCharCount() % 2

        return DoubleCutterHelper.cutIfTooManyLetters(word.text, maxChars: maxChars)
    }
}

class DoubleCutterNormalCipher: Cipher {
    func getTextForDecipher(_ word: Word) -> String {
        if (word.getCharCount() == 2) {
            return DoubleCutterHelper.replaceFirstNonDot(word.text)
        }

        //no more than 5 letters
        let maxChars = min(word.getCharCount() / 2, 5)

        return DoubleCutterHelper.cutIfTooManyLetters(word.text, maxChars: maxChars)
    }
}

class DoubleCutterHardCipher: Cipher {
    func getTextForDecipher(_ word: Word) -> String {
        if (word.getCharCount() == 2) {
            return DoubleCutterHelper.replaceFirstNonDot(word.text)
        }

        //no more than 2 letters
        let maxChars = min(word.getCharCount() / 2, 2)

        return DoubleCutterHelper.cutIfTooManyLetters(word.text, maxChars: maxChars)
    }
}

private class DoubleCutterHelper {
    class func cutIfTooManyLetters(_ word: String, maxChars: Int) -> String {
        let nonDotLength = DoubleCutterHelper.getNonDotLength(word)

        if (nonDotLength <= maxChars) {
            return word
        } else if (nonDotLength - maxChars == 1) {
            return DoubleCutterHelper.replaceFirstNonDot(word)
        } else {
            let cuttedWord = DoubleCutterHelper.replaceBothNonDot(word)
            return cutIfTooManyLetters(cuttedWord, maxChars: maxChars)
        }
    }

    class func getFirstNonDotIndex(_ word: String) -> Int {
        for i in 0..<word.characters.count {
            if (word[i] != ".") {
                return i
            }
        }

        return 0
    }

    class func getLastNonDotIndex(_ word: String) -> Int {
        for i in (0...(word.characters.count - 1)).reversed() {
            if (word[i] != ".") {
                return i
            }
        }

        return 0
    }

    class func getNonDotLength(_ word: String) -> Int {
        return DoubleCutterHelper.getLastNonDotIndex(word) - DoubleCutterHelper.getFirstNonDotIndex(word) + 1
    }

    class func replaceFirstNonDot(_ word: String) -> String {
        let firstNonDot = DoubleCutterHelper.getFirstNonDotIndex(word)
        return DoubleCutterHelper.replaceSymbolWithDot(word, firstNonDot)
    }

    class func replaceLastNonDot(_ word: String) -> String {
        let lastNonDot = DoubleCutterHelper.getLastNonDotIndex(word)
        return DoubleCutterHelper.replaceSymbolWithDot(word, lastNonDot)
    }

    class func replaceBothNonDot(_ word: String) -> String {
        let firstReplace = DoubleCutterHelper.replaceFirstNonDot(word)
        return DoubleCutterHelper.replaceLastNonDot(firstReplace)
    }

    class func replaceSymbolWithDot(_ word: String, _ index: Int) -> String {
        var newWord = ""

        for i in 0..<word.characters.count {
            if (i == index) {
                newWord = newWord + "."
            } else {
                newWord = newWord + word[i]
            }
        }

        return newWord
    }
}
