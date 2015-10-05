//
//  FirstLetterDecipher.swift
//  WTFChat
//
//  Created by Artem Chuzhmarov on 12/09/15.
//  Copyright (c) 2015 Artem Chuzhmarov. All rights reserved.
//

import Foundation

class HalfWordRoundUpCipher: Cipher {
    func getTextForDecipher(word: Word) -> String {
        let letterCount = word.getCharCount() / 2 + word.getCharCount() % 2 - 1
        return word.getCapitalized()[0...letterCount] + word.additional
    }
    
    func getDescription() -> String {
        return "HalfWordRoundUpCipher"
    }
}

class HalfWordRoundDownCipher: Cipher {
    func getTextForDecipher(word: Word) -> String {
        let letterCount = word.getCharCount() / 2 - 1
        return word.getCapitalized()[0...letterCount] + word.additional
    }
    
    func getDescription() -> String {
        return "HalfWordRoundDownCipher"
    }
}

class FirstLetterCipher: Cipher {
    func getTextForDecipher(word: Word) -> String {
        return word.getCapitalized()[0] + word.additional
    }
    
    func getDescription() -> String {
        return "FirstLetterCipher"
    }
}