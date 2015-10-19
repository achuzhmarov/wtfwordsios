//
//  LeftCutterCipher.swift
//  WTFChat
//
//  Created by Artem Chuzhmarov on 05/10/15.
//  Copyright © 2015 Artem Chuzhmarov. All rights reserved.
//

import Foundation

class ExceptTwoLettersFromEndCipher: Cipher {
    func getTextForDecipher(word: Word) -> String {
        let wordLength = word.getCharCount() - 1
        let letterCount = word.getCharCount() / 5 + 1
        
        return "..." + word.getLowerCase()[letterCount...wordLength] + word.additional
    }
}

class HalfWordRoundDownFromEndCipher: Cipher {
    func getTextForDecipher(word: Word) -> String {
        let wordLength = word.getCharCount() - 1
        var letterCount = word.getCharCount() / 2
        
        //4 letters max
        if (wordLength - letterCount > 3) {
            letterCount = wordLength - 3
        }
        
        return "..." + word.getLowerCase()[letterCount...wordLength] + word.additional
    }
}

class HalfWordPlusOneFromEndCipher: Cipher {
    func getTextForDecipher(word: Word) -> String {
        let wordLength = word.getCharCount() - 1
        var letterCount = word.getCharCount() / 2 //+ word.getCharCount() % 2
        
        if (wordLength > letterCount) {
            letterCount += 1
        }
        
        //3 letters max
        if (wordLength - letterCount > 2) {
            letterCount = wordLength - 2
        }
        
        return "..." + word.getLowerCase()[letterCount...wordLength] + word.additional
    }
}

/*class OneQuaterWordFromEndCipher: Cipher {
    func getTextForDecipher(word: Word) -> String {
        let wordLength = word.getCharCount() - 1
        let letterCount = (word.getCharCount() * 3) / 4
        return "..." + word.getLowerCase()[letterCount...wordLength] + word.additional
    }
}*/