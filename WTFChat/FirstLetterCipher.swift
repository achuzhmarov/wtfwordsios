//
//  FirstLetterDecipher.swift
//  WTFChat
//
//  Created by Artem Chuzhmarov on 12/09/15.
//  Copyright (c) 2015 Artem Chuzhmarov. All rights reserved.
//

import Foundation

class FirstLetterCipher: Cipher {
    func getTextForDecipher(word: Word) -> String {
        return word.text.capitalizedString[0] + word.additional
    }
    
    func getCipherType() -> CipherType {
        return CipherType.FirstLetterCipher
    }
}