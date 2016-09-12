import Foundation

class RightCutterEasyCipher: Cipher {
    func getTextForDecipher(word: Word) -> String {
        let letterCount = word.getCharCount() / 2 + word.getCharCount() % 2 - 1
        return "\(word.getCapitalized()[0...letterCount])...\(word.additional)"
    }
}

class RightCutterNormalCipher: Cipher {
    func getTextForDecipher(word: Word) -> String {
        var letterCount = word.getCharCount() / 2 - 1
        
        //5 letters max
        if (letterCount > 4) {
            letterCount = 4
        }
        
        return "\(word.getCapitalized()[0...letterCount])...\(word.additional)"
    }
}

class RightCutterHardCipher: Cipher {
    func getTextForDecipher(word: Word) -> String {
        return "\(word.getCapitalized()[0])...\(word.additional)"
    }
}