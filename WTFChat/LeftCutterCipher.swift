//
//  LeftCutterCipher.swift
//  WTFChat
//
//  Created by Artem Chuzhmarov on 05/10/15.
//  Copyright © 2015 Artem Chuzhmarov. All rights reserved.
//

import Foundation

class ExceptFirstLetterFromEndCipher: Cipher {
    func getTextForDecipher(word: Word) -> String {
        let wordLength = word.getCharCount() - 1
        return word.getCapitalized()[1...wordLength] + word.additional
    }
    
    func getDescription() -> String {
        return "ExceptFirstLetterFromEndCipher"
    }
}

class HalfWordRoundDownFromEndCipher: Cipher {
    func getTextForDecipher(word: Word) -> String {
        let wordLength = word.getCharCount() - 1
        let letterCount = (word.getCharCount() / 2 - 1) - 1
        return word.getCapitalized()[letterCount...wordLength] + word.additional
    }
    
    func getDescription() -> String {
        return "HalfWordRoundDownFromEndCipher"
    }
}

class HalfWordRoundUpFromEndCipher: Cipher {
    func getTextForDecipher(word: Word) -> String {
        let wordLength = word.getCharCount() - 1
        let letterCount = (word.getCharCount() / 2 + word.getCharCount() % 2 - 1) - 1
        return word.getCapitalized()[letterCount...wordLength] + word.additional
    }
    
    func getDescription() -> String {
        return "HalfWordRoundUpFromEndCipher"
    }
}