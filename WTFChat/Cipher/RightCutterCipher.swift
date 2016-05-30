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
        return "\(word.getCapitalized()[0...letterCount])...\(word.additional)"
    }
}

class HalfWordRoundDownCipher: Cipher {
    func getTextForDecipher(word: Word) -> String {
        var letterCount = word.getCharCount() / 2 - 1
        
        //5 letters max
        if (letterCount > 4) {
            letterCount = 4
        }
        
        return "\(word.getCapitalized()[0...letterCount])...\(word.additional)"
    }
}

class FirstLetterCipher: Cipher {
    func getTextForDecipher(word: Word) -> String {
        return "\(word.getCapitalized()[0])...\(word.additional)"
    }
}