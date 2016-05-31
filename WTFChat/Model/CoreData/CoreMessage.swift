//
//  CoreMessage.swift
//  WTFChat
//
//  Created by Artem Chuzhmarov on 29/12/15.
//  Copyright © 2015 Artem Chuzhmarov. All rights reserved.
//

import Foundation
import CoreData

let CORE_WORD_CLASS_NAME = "CoreWord"
let CORE_MESSAGE_CLASS_NAME = "CoreMessage"

class CoreMessage: NSManagedObject {
    
    func updateFromMessageWithoutWords(message: Message) {
        self.id = message.id
        self.timestamp = message.timestamp
        self.lastUpdate = message.lastUpdate
        self.talkId = message.talkId
        self.author = message.author
        self.deciphered = message.deciphered
        self.cipherType = message.cipherType.rawValue
        self.exp = message.exp
        self.isLocal = message.isLocal
        self.extId = message.extId
        self.timerSecs = message.timerSecs
        self.hintsUsed = message.hintsUsed
    }
    
    func getMessage() -> Message? {
        if (self.id == nil ||
            self.timestamp == nil ||
            self.lastUpdate == nil ||
            self.talkId == nil ||
            self.author == nil ||
            self.deciphered == nil ||
            self.cipherType == nil ||
            self.exp == nil ||
            self.isLocal == nil ||
            self.extId == nil ||
            self.timerSecs == nil ||
            self.hintsUsed == nil ||
            self.words == nil) {
                
                return nil
        }
        
        if let enumCipherType = CipherType(rawValue: Int(self.cipherType!)) {
            var domainWords = [Word]()
            
            for item in self.words! {
                if let coreWord = item as? CoreWord {
                    if let domainWord = coreWord.getWord() {
                        domainWords.append(domainWord)
                    }
                }
            }
            
            let message = Message(
                id: self.id!,
                talkId: self.talkId!,
                author: self.author!,
                words: domainWords,
                deciphered: Bool(self.deciphered!),
                cipherType: enumCipherType,
                timestamp: self.timestamp!,
                lastUpdate: self.lastUpdate!,
                exp: Int(self.exp!),
                extId: self.extId!,
                timerSecs: Int(self.timerSecs!),
                hintsUsed: Int(self.hintsUsed!)
            )
            
            message.isLocal = Bool(self.isLocal!)
            
            return message
        } else {
            return nil
        }
    }
}
