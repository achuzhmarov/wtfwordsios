import Foundation

class DoubleCutterEasyCipher: Cipher {
    func getTextForDecipher(_ word: Word) -> String {
        if (word.getCharCount() == 2) {
            return DoubleCutterHelper.replaceFirstNonDot(word.getLowerCase())
        }
        
        let odd = ((word.getCharCount() % 2) == 1)
        return DoubleCutterHelper.cutWord(word.getLowerCase(), odd: odd)
    }
}

class DoubleCutterNormalCipher: Cipher {
    func getTextForDecipher(_ word: Word) -> String {
        if (word.getCharCount() == 2) {
            return DoubleCutterHelper.replaceFirstNonDot(word.getLowerCase())
        }
        
        let odd = ((word.getCharCount() % 2) == 1)
        let ciphered = DoubleCutterHelper.cutWord(word.getLowerCase(), odd: odd)

        var maxChars: Int
        
        if (word.getCharCount() < 4) {
            maxChars = 1
        } else if (word.getCharCount() < 7) {
            maxChars = 3
        } else {
            maxChars = 4
        }

        return DoubleCutterHelper.cutIfTooManyLetters(ciphered, odd: odd, maxChars: maxChars)
    }
}

class DoubleCutterHardCipher: Cipher {
    func getTextForDecipher(_ word: Word) -> String {
        if (word.getCharCount() == 2) {
            return DoubleCutterHelper.replaceFirstNonDot(word.getLowerCase())
        }
        
        let odd = ((word.getCharCount() % 2) == 1)
        let easyCiphered = DoubleCutterHelper.cutWord(word.getLowerCase(), odd: odd)
        let hardCiphered = DoubleCutterHelper.cutWord(easyCiphered, odd: odd)

        return DoubleCutterHelper.cutIfTooManyLetters(hardCiphered, odd: odd, maxChars: 2)
    }
}

private class DoubleCutterHelper {
    class func cutIfTooManyLetters(_ word: String, odd: Bool, maxChars: Int) -> String {
        let nonDotLength = DoubleCutterHelper.getNonDotLength(word)

        if (nonDotLength <= maxChars) {
            return word
        } else if (nonDotLength - maxChars == 1) {
            if (odd) {
                return DoubleCutterHelper.replaceLastNonDot(word)
            } else {
                return DoubleCutterHelper.replaceFirstNonDot(word)
            }
        } else {
            let cuttedWord = DoubleCutterHelper.cutWord(word, odd: odd)
            return cutIfTooManyLetters(cuttedWord, odd: odd, maxChars: maxChars)
        }
    }
    
    class func cutWord(_ word: String, odd: Bool) -> String {
        let nonDotLength = DoubleCutterHelper.getNonDotLength(word)

        if (nonDotLength == 1) {
            return word
        } else if (nonDotLength == 2) {
            if (odd) {
                return DoubleCutterHelper.replaceLastNonDot(word)
            } else {
                return word
            }
        } else if (nonDotLength == 3) {
            return DoubleCutterHelper.replaceFirstNonDot(word)
        } else {
            return DoubleCutterHelper.replaceBothNonDot(word)
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
        for i in (word.characters.count - 1)...0 {
            if (word[i] != ".") {
                return i
            }
        }

        return 0
    }

    class func getNonDotLength(_ word: String) -> Int {
        return DoubleCutterHelper.getLastNonDotIndex(word) - DoubleCutterHelper.getFirstNonDotIndex(word)
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
