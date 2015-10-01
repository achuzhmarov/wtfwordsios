//
//  ShuffleCipher.swift
//  WTFChat
//
//  Created by Artem Chuzhmarov on 12/09/15.
//  Copyright (c) 2015 Artem Chuzhmarov. All rights reserved.
//

import Foundation

class ShuffleCipher: Cipher {
    func getTextForDecipher(word: Word) -> String {
        return word.text.uppercaseString.shuffle + word.additional
    }
    
    func getCipherType() -> CipherType {
        return CipherType.ShuffleCipher
    }
}