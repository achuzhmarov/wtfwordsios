//
//  CoreWord.swift
//  WTFChat
//
//  Created by Artem Chuzhmarov on 29/12/15.
//  Copyright © 2015 Artem Chuzhmarov. All rights reserved.
//

import Foundation
import CoreData

class CoreWord: NSManagedObject {
    func updateFromWord(word: Word) {
        self.text = word.text
        self.additional = word.additional
        self.wordType = word.wordType.rawValue
        self.cipheredText = word.cipheredText
        self.wasCloseTry = word.wasCloseTry
    }
    
    func getWord() -> Word? {
        if (self.text == nil ||
            self.additional == nil ||
            self.cipheredText == nil ||
            self.wasCloseTry == nil ||
            self.wordType == nil) {
                
            return nil
        }
        
        if let enumWordType = WordType(rawValue: Int(self.wordType!)) {
            return Word(
                text: self.text!,
                additional: self.additional!,
                wordType: enumWordType,
                cipheredText: self.cipheredText!,
                wasCloseTry: Bool(self.wasCloseTry!)
            )
        } else {
            return nil
        }
    }
}
