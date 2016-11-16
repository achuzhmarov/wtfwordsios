import Foundation

class RightCutterEasyCipher: Cipher {
    func getTextForDecipher(_ word: Word) -> String {
        let letterCount = word.getCharCount() / 2 + word.getCharCount() % 2 - 1

        return word.text[0...letterCount] + CipherHelper.getNDots(word.getCharCount() - letterCount)
    }
}

class RightCutterNormalCipher: Cipher {
    func getTextForDecipher(_ word: Word) -> String {
        var letterCount = word.getCharCount() / 2 - 1
        
        //5 letters max
        if (letterCount > 4) {
            letterCount = 4
        }
        
        return word.text[0...letterCount] + CipherHelper.getNDots(word.getCharCount() - letterCount)
    }
}

class RightCutterHardCipher: Cipher {
    func getTextForDecipher(_ word: Word) -> String {
        return word.text[0] + CipherHelper.getNDots(word.getCharCount() - 1)
    }
}
