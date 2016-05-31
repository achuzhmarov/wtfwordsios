//
//  LeftCutterCipher.swift
//  WTFChat
//
//  Created by Artem Chuzhmarov on 05/10/15.
//  Copyright © 2015 Artem Chuzhmarov. All rights reserved.
//

import Foundation

class LeftCutterEasyCipher: Cipher {
    func getTextForDecipher(word: Word) -> String {
        let wordLength = word.getCharCount() - 1
        let letterCount = word.getCharCount() / 5 + 1
        
        return "...\(word.getLowerCase()[letterCount...wordLength])\(word.additional)"
    }
}

class LeftCutterNormalCipher: Cipher {
    func getTextForDecipher(word: Word) -> String {
        let wordLength = word.getCharCount() - 1
        var letterCount = word.getCharCount() / 2 + word.getCharCount() % 2
        
        //4 letters max
        if (wordLength - letterCount > 3) {
            letterCount = wordLength - 3
        }
        
        return "...\(word.getLowerCase()[letterCount...wordLength])\(word.additional)"
    }
}

class LeftCutterHardCipher: Cipher {
    func getTextForDecipher(word: Word) -> String {
        let wordLength = word.getCharCount() - 1
        var letterCount = word.getCharCount() / 2 + word.getCharCount() % 2
        
        if (wordLength > letterCount) {
            letterCount += 1
        }
        
        //2 letters max
        if (wordLength - letterCount > 1) {
            letterCount = wordLength - 1
        }
        
        return "...\(word.getLowerCase()[letterCount...wordLength])\(word.additional)"
    }
}