//
//  MessageCipherService.swift
//  WTFChat
//
//  Created by Artem Chuzhmarov on 24/09/15.
//  Copyright © 2015 Artem Chuzhmarov. All rights reserved.
//

import Foundation

class MessageCipherService {
    private let WORD_SPECIAL_SYMBOLS = ["'", "-"]

    private let currentUserService: CurrentUserService

    init(currentUserService: CurrentUserService) {
        self.currentUserService = currentUserService
    }

    func getCompareString(string: String) -> String {
        return string.uppercaseString.removeChars(WORD_SPECIAL_SYMBOLS).replace("Ё", with: "Е")
    }
    
    func decipher(message: Message, guessText: String) {
        let guessWords = guessText.characters.split {$0 == " "}.map { String($0) }
        
        let words = message.words
        
        for guessWord in guessWords {
            let guesses = parseGuessForCompare(guessWord)
            
            for guess in guesses {
                for word in words! {
                    if (word.wordType == WordType.New && getCompareString(word.text) == guess) {
                        word.wordType = WordType.Success
                    }
                }
            }
        }
        
        checkDeciphered(message)
    }
    
    func wasCloseTry(word: Word, guessWords: [String]?) -> Bool {
        if (guessWords == nil) {
            return false
        }
        
        for guessWord in guessWords! {
            let guesses = parseGuessForCompare(guessWord)
            
            for guess in guesses {
                if Tools.calcStringDistance(getCompareString(word.text), bStr: guess) == 1 {
                    return true
                }
            }
        }
        
        return false
    }
    
    func parseGuessForCompare(guessWord: String) -> [String] {
        var result = [String]()
        var newWordText = ""
        var isLastLetter = true
        
        for uniChar in guessWord.unicodeScalars {
            if (isLastLetter) {
                if (isLetter(uniChar)) {
                    newWordText += String(uniChar)
                } else {
                    isLastLetter = false
                    
                    //add word to result
                    result.append(getCompareString(newWordText))
                    newWordText = ""
                    
                    //skip current symbol
                }
            } else {
                if (isLetter(uniChar)) {
                    isLastLetter = true
                    
                    //save letter to new word
                    newWordText = String(uniChar)
                } else {
                    //skip current symbol
                }
            }
        }
        
        if (isLastLetter) {
            result.append(getCompareString(newWordText))
        }
        
        return result
    }
    
    func decipher(message: Message, suggestedWord: Word, closeTry: Bool = false) {
        if (closeTry) {
            suggestedWord.wordType = WordType.CloseTry
        } else {
            suggestedWord.wordType = WordType.Success
        }
        
        checkDeciphered(message)
    }
    
    private func checkDeciphered(message: Message) {
        if (message.countNew() == 0) {
            message.deciphered = true
            message.lastUpdate = NSDate()
        }
    }
    
    func failed(message: Message) {
        for word in message.words! {
            if (word.wordType == WordType.New) {
                if (word.wasCloseTry) {
                    word.wordType = WordType.CloseTry
                } else {
                    word.wordType = WordType.Failed
                }
            }
        }
        
        message.deciphered = true
    }
    
    func createMessage(talk: Talk, text: String, cipherType: CipherType) -> Message {
        let generatedMessage = createMessage(text, cipherType: cipherType)
        return addNewMessageToTalk(generatedMessage, talk: talk)
    }
    
    func addNewMessageToTalk(generatedMessage: Message, talk: Talk) -> Message {
        var author: String
        
        if (talk.isSingleMode) {
            author = talk.users[0]
        } else {
            author = currentUserService.getUserLogin()
        }
        
        let newMessage = Message(id: "",
            talkId: talk.id,
            author: author,
            words: generatedMessage.words,
            cipherType: generatedMessage.cipherType
        )
        
        newMessage.isLocal = true
        newMessage.extId = NSUUID().UUIDString
        checkDeciphered(newMessage)
        
        talk.appendMessage(newMessage)
        
        return newMessage
    }
    
    func createMessage(text: String, cipherType: CipherType) -> Message {
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
        
        let newMessage = Message(id: "",
            talkId: "",
            author: "",
            words: words,
            cipherType: cipherType
        )
        
        newMessage.cipherWords()
        checkDeciphered(newMessage)
        
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
                    
                    /*words.append(Word(text: newWordText, additional: newWordAdditional, wordType: getWordType(newWordText)))
                    
                    newWordText = ""
                    newWordAdditional = String(uniChar)*/
                    
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
        if (countLettersOnly(newWordText) <= 1) {
            return WordType.Ignore
        } else {
            return WordType.New
        }
    }
    
    private let letters = NSCharacterSet.letterCharacterSet()
    private func isLetter(unicodeChar: UnicodeScalar) -> Bool {
        if isLetterOnly(unicodeChar) {
            return true
        } else {
            for wordSymbol in WORD_SPECIAL_SYMBOLS {
                if String(unicodeChar) == wordSymbol {
                    return true
                }
            }
        }
        
        return false
    }
    
    private func isLetterOnly(unicodeChar: UnicodeScalar) -> Bool {
        if letters.longCharacterIsMember(unicodeChar.value) {
            return true
        }
        
        return false
    }
    
    private func countLettersOnly(string: String) -> Int {
        var result = 0
        
        for char in string.unicodeScalars {
            if isLetterOnly(char) {
                result += 1
            }
        }
        
        return result
    }
}