//
//  MessageCipher.swift
//  WTFChat
//
//  Created by Artem Chuzhmarov on 24/09/15.
//  Copyright © 2015 Artem Chuzhmarov. All rights reserved.
//

import Foundation

let messageCipher = MessageCipher()

class MessageCipher {
    func decipher(message: Message, guessText: String) {
        let guessWords = guessText.characters.split {$0 == " "}.map { String($0) }
        
        let words = message.words
        
        for guessWord in guessWords {
            for word in words! {
                if (word.wordType == WordType.New
                    && word.text.uppercaseString == guessWord.uppercaseString) {
                            
                    word.wordType = WordType.Success
                }
            }
        }
        
        checkDeciphered(message)
    }
    
    func decipher(message: Message, suggestedWord: Word) {
        suggestedWord.wordType = WordType.Success
        checkDeciphered(message)
    }
    
    private func checkDeciphered(message: Message) {
        if (message.countNew() == 0) {
            message.deciphered = true
        }
    }
    
    func failed(message: Message) {
        for word in message.words! {
            if (word.wordType == WordType.New) {
                word.wordType = WordType.Failed
            }
        }
        
        message.deciphered = true
    }
    
    func createMessage(talk: Talk, text: String, cipherType: CipherType = CipherType.FirstLetterCipher) -> Message {
        let strings = text.characters.split {$0 == "\n"}.map { String($0) }
        
        var firstSentence = true
        
        var words = [Word]()
        
        for curString in strings {
            if (firstSentence) {
                firstSentence = false
            } else {
                words.append(Word.lineBreakWord())
            }
            
            let textWords = curString.characters.split {$0 == " "}.map { String($0) }
            
            var firstWord = true
            
            for textWord in textWords {
                if (firstWord) {
                    firstWord = false
                } else {
                    words.append(Word.delimiterWord())
                }
                
                words.appendContentsOf(createWords(textWord))
            }
        }
        
        var author: String
        
        if (talk.isSingleMode) {
            author = talk.users[0]
        } else {
            author = userService.getCurrentUser().login
        }
        
        let newMessage = Message(id: "",
            talkId: talk.id,
            author: author,
            words: words,
            cipherType: cipherType
        )
        
        newMessage.cipherWords()
        
        checkDeciphered(newMessage)
        
        talk.appendMessage(newMessage)
        
        return newMessage
    }
    
    private func createWords(textWord: String) -> [Word] {
        var words = [Word]()
        
        var newWordText = ""
        var newWordAdditional = ""
        
        var isLastLetter = true
        
        for uniChar in textWord.unicodeScalars {
            if (isLastLetter) {
                if (isLetter(uniChar)) {
                    newWordText += String(uniChar)
                } else {
                    isLastLetter = false
                    newWordAdditional += String(uniChar)
                }
            } else {
                if (isLetter(uniChar)) {
                    isLastLetter = true
                    
                    words.append(Word(text: newWordText, additional: newWordAdditional, wordType: getWordType(newWordText)))
                    
                    newWordText = String(uniChar)
                    newWordAdditional = ""
                } else {
                    newWordAdditional += String(uniChar)
                }
            }
        }
        
        words.append(Word(text: newWordText, additional: newWordAdditional, wordType: getWordType(newWordText)))
        
        return words
    }
    
    private func getWordType(newWordText: String) -> WordType {
        if (newWordText.characters.count <= 1) {
            return WordType.Ignore
        } else {
            return WordType.New
        }
    }
    
    private let letters = NSCharacterSet.letterCharacterSet()
    private func isLetter(unicodeChar: UnicodeScalar) -> Bool {
        return letters.longCharacterIsMember(unicodeChar.value)
        //|| String(unicodeChar) == "'"
        //|| String(unicodeChar) == "-"
    }
    
    //let digits = NSCharacterSet.decimalDigitCharacterSet()
    /*func isDigit(unicodeChar: UnicodeScalar) -> Bool {
    return digits.longCharacterIsMember(unicodeChar.value)
    }*/
}