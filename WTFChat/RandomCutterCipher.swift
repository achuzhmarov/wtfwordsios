//
//  RandomCutterCipher.swift
//  WTFChat
//
//  Created by Artem Chuzhmarov on 19/10/15.
//  Copyright © 2015 Artem Chuzhmarov. All rights reserved.
//

import Foundation

class EasyRandomCutterCipher: Cipher {
    func getTextForDecipher(word: Word) -> String {
        let charsLeft = word.getCharCount() / 2 + word.getCharCount() % 2
        
        let ciphered = RandomCutterHelper.CutRandomLetters(word.getLowerCase(), charsLeft: charsLeft)
        return ciphered + word.additional
    }
}

class NormalRandomCutterCipher: Cipher {
    func getTextForDecipher(word: Word) -> String {
        let charsLeft = word.getCharCount() / 2
        
        let ciphered = RandomCutterHelper.CutRandomLetters(word.getLowerCase(), charsLeft: charsLeft)
        return ciphered + word.additional
    }
}

class HardRandomCutterCipher: Cipher {
    func getTextForDecipher(word: Word) -> String {
        var charsLeft = word.getCharCount() / 2
        
        if (word.getCharCount() > 5) {
            charsLeft = 3
        }
        
        let ciphered = RandomCutterHelper.CutRandomLetters(word.getLowerCase(), charsLeft: charsLeft)
        return ciphered + word.additional
    }
}


private class RandomCutterHelper {
    class func CutRandomLetter(word: String) -> String {
        let randomIndex = Int(arc4random_uniform(UInt32(word.characters.count)))
        
        if (word[randomIndex] != ".") {
            var newWord = ""
            
            for i in 0..<word.characters.count {
                if (i == randomIndex) {
                    newWord += "."
                } else {
                    newWord += word[i]
                }
            }
            
            return newWord
        } else {
            //try again
            return CutRandomLetter(word)
        }
    }
    
    class func parseResultWord(word: String) -> String {
        var newWord = ""
        var isLastCharDot = false
        
        for i in 0..<word.characters.count {
            if (word[i] == ".") {
                if (isLastCharDot) {
                    //skip
                } else {
                    newWord += "..."
                }
                
                isLastCharDot = true
            } else {
                isLastCharDot = false
                newWord += word[i]
            }
        }
        
        return newWord
    }
    
    class func CutRandomLetters(word: String, charsLeft: Int) -> String {
        var result = word
        
        let charsToCut = word.characters.count - charsLeft
        
        for _ in 0..<charsToCut {
            result = CutRandomLetter(result)
        }
        
        return parseResultWord(result)
    }
}
