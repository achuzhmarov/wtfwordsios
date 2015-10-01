//
//  HalfWordRoundUpDecipher.swift
//  WTFChat
//
//  Created by Artem Chuzhmarov on 12/09/15.
//  Copyright (c) 2015 Artem Chuzhmarov. All rights reserved.
//

import Foundation

class HalfWordRoundUpCipher: Cipher {
    func getTextForDecipher(word: Word) -> String {
        let letterCount = word.text.characters.count / 2 + word.text.characters.count % 2 - 1
        return word.text.capitalizedString[0...letterCount] + word.additional
    }
    
    func getCipherType() -> CipherType {
        return CipherType.HalfWordRoundUpCipher
    }
}