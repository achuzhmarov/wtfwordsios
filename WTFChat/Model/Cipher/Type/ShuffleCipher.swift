import Foundation

class ShuffleEasyCipher: Cipher {
    func getTextForDecipher(_ word: Word) -> String {
        let wordLength = word.getCharCount() - 1
        
        let firstLetter: String = word.getLowerCase()[0]
        let shuffled = word.getUpperCase()[1...wordLength].shuffle
        
        return "\(firstLetter)\(shuffled)\(word.additional)"
    }
}

class ShuffleNormalCipher: Cipher {
    func getTextForDecipher(_ word: Word) -> String {
        return "\(word.getUpperCase().shuffle)\(word.additional)"
    }
}

class ShuffleHardCipher: Cipher {
    func getTextForDecipher(_ word: Word) -> String {
        var wordLength = word.getCharCount() - 1

        //cut last letter
        if (word.getCharCount() > 2) {
            wordLength -= 1
        }
        
        let shuffled = "...\(word.getUpperCase()[1...wordLength].shuffle)..."
        return shuffled + word.additional
    }
}
