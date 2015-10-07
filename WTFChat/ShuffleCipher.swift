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
        
        let firstLetter: String = word.getLowerCase()[0]
        let shuffled = word.getUpperCase()[1...wordLength].shuffle
        
        return firstLetter + shuffled + word.additional
    }
}

class ShuffleFullWordCipher: Cipher {
    func getTextForDecipher(word: Word) -> String {
        return word.getUpperCase().shuffle + word.additional
    }
}

class ShuffleWithExtraLetterCipher: Cipher {
    func getTextForDecipher(word: Word) -> String {
        let wordLength = word.getCharCount() - 1
        
        let shuffled = "..." + word.getUpperCase()[1...wordLength].shuffle
        return shuffled + word.additional
    }
}