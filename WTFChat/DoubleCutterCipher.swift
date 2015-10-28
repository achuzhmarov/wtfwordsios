//
//  DoubleCutterCipher.swift
//  WTFChat
//
//  Created by Artem Chuzhmarov on 19/10/15.
//  Copyright © 2015 Artem Chuzhmarov. All rights reserved.
//

import Foundation

class OneLetterFromBothEndsCipher: Cipher {
    func getTextForDecipher(word: Word) -> String {
        if (word.getCharCount() == 2) {
            return "..." + word.getLowerCase()[1] + "..." + word.additional
        }
        
        let odd = ((word.getCharCount() % 2) == 1)
        let easyCiphered = DoubleCutterHelper.cutWord(word.getLowerCase(), odd: odd)
            
        let cuttedEasyCiphered = DoubleCutterHelper.cutIfTooManyLetters(easyCiphered, odd: odd, maxChars: 6)
            
        return "..." + cuttedEasyCiphered + "..." + word.additional
    }
}

class TwoLettersFromBothEndsCipher: Cipher {
    func getTextForDecipher(word: Word) -> String {
        if (word.getCharCount() == 2) {
            return "..." + word.getLowerCase()[1] + "..." + word.additional
        }
        
        let odd = ((word.getCharCount() % 2) == 1)
        var ciphered = DoubleCutterHelper.cutWord(word.getLowerCase(), odd: odd)
        
        let cipheredLength = ciphered.characters.count
        if (cipheredLength > 1) {
            ciphered = ciphered[1...cipheredLength-1]
        }

        let cuttedNormalCiphered = DoubleCutterHelper.cutIfTooManyLetters(ciphered, odd: odd, maxChars: 5)
        
        return "..." + cuttedNormalCiphered + "..." + word.additional
    }
}

class ThreeLettersFromBothEndsCipher: Cipher {
    func getTextForDecipher(word: Word) -> String {
        if (word.getCharCount() == 2) {
            return "..." + word.getLowerCase()[1] + "..." + word.additional
        }
        
        let odd = ((word.getCharCount() % 2) == 1)
        let easyCiphered = DoubleCutterHelper.cutWord(word.getLowerCase(), odd: odd)
        let hardCiphered = DoubleCutterHelper.cutWord(easyCiphered, odd: odd)
        
        let cuttedHardCiphered = DoubleCutterHelper.cutIfTooManyLetters(hardCiphered, odd: odd, maxChars: 4)
        
        return "..." + cuttedHardCiphered + "..." + word.additional
    }
}

private class DoubleCutterHelper {
    class func cutIfTooManyLetters(word: String, odd: Bool, maxChars: Int) -> String {
        if (word.characters.count <= maxChars) {
            return word
        } else if (word.characters.count - maxChars == 1) {
            let wordLength = word.characters.count - 1
            
            if (odd) {
                //cut last character
                let length = wordLength - 1
                return word[0...length]
            } else {
                //cut first character
                return word[1...wordLength]
            }
        } else {
            let cuttedWord = DoubleCutterHelper.cutWord(word, odd: odd)
            return cutIfTooManyLetters(cuttedWord, odd: odd, maxChars: maxChars)
        }
    }
    
    class func cutWord(word: String, odd: Bool) -> String {
        if (word.characters.count == 1) {
            return word
        } else if (word.characters.count == 2) {
            if (odd) {
                return word[0]
            } else {
                return word
            }
        } else if (word.characters.count == 3) {
            return word[1...2]
        } else {
            //cut last letter from index value
            let length = (word.characters.count - 1) - 1
            
            return word[1...length]
        }
    }
}