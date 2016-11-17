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
        
        //4 letters max
        if (wordLength - letterCount > 3) {
            letterCount = wordLength - 3
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
        
        //2 letters max
        if (wordLength - letterCount > 1) {
            letterCount = wordLength - 1
        }
        
        return CipherHelper.getNDots(letterCount) + word.getLowerCase()[letterCount...wordLength]
    }
}
