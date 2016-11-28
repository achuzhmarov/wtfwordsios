import Foundation

class RandomCutterEasyCipher: Cipher {
    func getTextForDecipher(_ word: Word) -> String {
        let charsLeft = word.getCharCount() / 2 + word.getCharCount() % 2

        return RandomCutterHelper.CutRandomLetters(word.text, charsLeft: charsLeft)
    }
}

class RandomCutterNormalCipher: Cipher {
    func getTextForDecipher(_ word: Word) -> String {
        var charsLeft = word.getCharCount() / 2

        //set max letters
        charsLeft = min(charsLeft, 5)

        return RandomCutterHelper.CutRandomLetters(word.text, charsLeft: charsLeft)
    }
}

class RandomCutterHardCipher: Cipher {
    func getTextForDecipher(_ word: Word) -> String {
        var charsLeft = word.getCharCount() / 2

        charsLeft = min(charsLeft, 3)

        return RandomCutterHelper.CutRandomLetters(word.text, charsLeft: charsLeft)
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
    
    class func CutRandomLetters(_ word: String, charsLeft: Int) -> String {
        var result = word
        
        let charsToCut = word.characters.count - charsLeft
        
        for _ in 0..<charsToCut {
            result = CutRandomLetter(result)
        }
        
        return result
    }
}
