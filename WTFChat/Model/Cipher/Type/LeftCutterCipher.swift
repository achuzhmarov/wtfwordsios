import Foundation

class LeftCutterEasyCipher: Cipher {
    func getTextForDecipher(_ word: Word) -> String {
        let wordLength = word.getCharCount() - 1
        let letterCount = word.getCharCount() / 5 + 1
        
        return  CipherHelper.getNDots(letterCount) + word.getLowerCase()[letterCount...wordLength]
    }
}

class LeftCutterNormalCipher: Cipher {
    func getTextForDecipher(_ word: Word) -> String {
        let wordLength = word.getCharCount() - 1
        var letterCount = word.getCharCount() / 2 + word.getCharCount() % 2
        
        //5 letters max
        if (wordLength - letterCount > 4) {
            letterCount = wordLength - 4
        }
        
        return CipherHelper.getNDots(letterCount) + word.getLowerCase()[letterCount...wordLength]
    }
}

class LeftCutterHardCipher: Cipher {
    func getTextForDecipher(_ word: Word) -> String {
        let wordLength = word.getCharCount() - 1
        var letterCount = word.getCharCount() / 2 + word.getCharCount() % 2
        
        if (wordLength > letterCount) {
            letterCount += 1
        }
        
        //3 letters max
        if (wordLength - letterCount > 2) {
            letterCount = wordLength - 2
        }
        
        return CipherHelper.getNDots(letterCount) + word.getLowerCase()[letterCount...wordLength]
    }
}
