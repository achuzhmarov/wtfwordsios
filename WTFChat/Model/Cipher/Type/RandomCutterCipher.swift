import Foundation

class RandomCutterEasyCipher: Cipher {
    func getTextForDecipher(_ word: Word) -> String {
        let charsLeft = word.getCharCount() / 2 + word.getCharCount() % 2
        
        let ciphered = RandomCutterHelper.CutRandomLetters(word.text, charsLeft: charsLeft)
        return "\(ciphered)\(word.additional)"
    }
}

class RandomCutterNormalCipher: Cipher {
    func getTextForDecipher(_ word: Word) -> String {
        var charsLeft = word.getCharCount() / 2
        
        if (word.getCharCount() > 5) {
            charsLeft = 3
        }
        
        let ciphered = RandomCutterHelper.CutRandomLetters(word.text, charsLeft: charsLeft)
        return "\(ciphered)\(word.additional)"
    }
}

class RandomCutterHardCipher: Cipher {
    func getTextForDecipher(_ word: Word) -> String {
        var charsLeft = word.getCharCount() / 2
        
        if (word.getCharCount() > 5) {
            charsLeft = 2
        }
        
        let ciphered = RandomCutterHelper.CutRandomLetters(word.text, charsLeft: charsLeft)
        return "\(ciphered)\(word.additional)"
    }
}


private class RandomCutterHelper {
    class func CutRandomLetter(_ word: String) -> String {
        let randomIndex = Int(arc4random_uniform(UInt32(word.characters.count)))
        
        if (word[randomIndex] != ".") {
            var newWord = ""
            
            for i in 0..<word.characters.count {
                if (i == randomIndex) {
                    newWord = "\(newWord)."
                } else {
                    newWord = "\(newWord)\(word[i])"
                }
            }
            
            return newWord
        } else {
            //try again
            return CutRandomLetter(word)
        }
    }
    
    class func parseResultWord(_ word: String) -> String {
        var newWord = ""
        var isLastCharDot = false
        
        for i in 0..<word.characters.count {
            if (word[i] == ".") {
                if (isLastCharDot) {
                    //skip
                } else {
                    newWord = "\(newWord)..."
                }
                
                isLastCharDot = true
            } else {
                isLastCharDot = false
                newWord = "\(newWord)\(word[i])"
            }
        }
        
        return newWord
    }
    
    class func CutRandomLetters(_ word: String, charsLeft: Int) -> String {
        var result = word
        
        let charsToCut = word.characters.count - charsLeft
        
        for _ in 0..<charsToCut {
            result = CutRandomLetter(result)
        }
        
        return parseResultWord(result)
    }
}
