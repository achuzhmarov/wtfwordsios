//
//  ShuffleCipher.swift
//  WTFChat
//
//  Created by Artem Chuzhmarov on 12/09/15.
//  Copyright (c) 2015 Artem Chuzhmarov. All rights reserved.
//

import Foundation

class ShuffleExceptFirstLetterCipher: Cipher {
    func getTextForDecipher(word: Word) -> String {
        let wordLength = word.getCharCount() - 1
        
        let firstLetter: String = word.getUpperCase()[0]
        let shuffled = word.getUpperCase()[1...wordLength].shuffle
        
        return firstLetter + shuffled + word.additional
    }
    
    func getDescription() -> String {
        return "ShuffleExceptFirstLetterCipher"
    }
}

class ShuffleFullWordCipher: Cipher {
    func getTextForDecipher(word: Word) -> String {
        return word.getUpperCase().shuffle + word.additional
    }
    
    func getDescription() -> String {
        return "ShuffleFullWordCipher"
    }
}

class ShuffleWithExtraLetterCipher: Cipher {
    func getTextForDecipher(word: Word) -> String {
        let randomLetter: String = word.getUpperCase().shuffle[0]
        let shuffled = (word.getUpperCase() + randomLetter).shuffle
        return shuffled + word.additional
    }
    
    func getDescription() -> String {
        return "ShuffleWithExtraLetterCipher"
    }
}