//
//  DecipherFactory.swift
//  WTFChat
//
//  Created by Artem Chuzhmarov on 12/09/15.
//  Copyright (c) 2015 Artem Chuzhmarov. All rights reserved.
//

import Foundation

protocol Cipher {
    func getTextForDecipher(word: Word) -> String
    func getDescription() -> String
}

enum CipherType : Int {
    case HalfWordRoundUp = 1
    case HalfWordRoundDown
    case FirstLetter

    case ExceptFirstLetterFromEnd
    case HalfWordRoundDownFromEnd
    case HalfWordRoundUpFromEnd
    
    case ShuffleExceptFirstLetter
    case ShuffleFullWord
    case ShuffleWithExtraLetter
}

enum CipherCategory : Int, CustomStringConvertible {
    case RightCutter = 1
    case LeftCutter
    case Shuffle
    
    var description : String {
        get {
            switch self {
            case CipherCategory.RightCutter:
                return "Right Cutter"
            case CipherCategory.LeftCutter:
                return "Left Cutter"
            case CipherCategory.Shuffle:
                return "Shuffle"
            }
        }
    }
}

enum CipherMode : Int, CustomStringConvertible {
    case Easy = 1
    case Normal
    case Hard
    
    var description : String {
        get {
            switch self {
            case CipherMode.Easy:
                return "Easy"
            case CipherMode.Normal:
                return "Normal"
            case CipherMode.Hard:
                return "Hard"
            }
        }
    }
}

class CipherFactory {
    static let ciphers: [CipherType: Cipher] = [
        .HalfWordRoundUp: HalfWordRoundUpCipher(),
        .HalfWordRoundDown: HalfWordRoundDownCipher(),
        .FirstLetter: FirstLetterCipher(),
        .ExceptFirstLetterFromEnd: ExceptFirstLetterFromEndCipher(),
        .HalfWordRoundDownFromEnd: HalfWordRoundDownFromEndCipher(),
        .HalfWordRoundUpFromEnd: HalfWordRoundUpFromEndCipher(),
        .ShuffleExceptFirstLetter: ShuffleExceptFirstLetterCipher(),
        .ShuffleFullWord: ShuffleFullWordCipher(),
        .ShuffleWithExtraLetter: ShuffleWithExtraLetterCipher()
    ]
    
    static let cipherTypes: [CipherCategory: [CipherMode: CipherType]] = [
        .RightCutter: [
            .Easy: .HalfWordRoundUp,
            .Normal: .HalfWordRoundDown,
            .Hard: .FirstLetter
        ],
        .LeftCutter: [
            .Easy: .ExceptFirstLetterFromEnd,
            .Normal: .HalfWordRoundDownFromEnd,
            .Hard: .HalfWordRoundUpFromEnd
        ],
        .Shuffle: [
            .Easy: .ShuffleExceptFirstLetter,
            .Normal: .ShuffleFullWord,
            .Hard: .ShuffleWithExtraLetter
        ]
        
    ]
    
    class func getDescription(cipherType: CipherType) -> String {
        return ciphers[cipherType]!.getDescription()
    }
    
    class func cipherText(cipherType: CipherType, word: Word) -> String {
        return ciphers[cipherType]!.getTextForDecipher(word)
    }
    
    class func getCipherType(category: CipherCategory, mode: CipherMode) -> CipherType {
        return cipherTypes[category]![mode]!
    }
    
    class func getCategoryAndMode(cipherType: CipherType) -> (CipherCategory, CipherMode) {
        for category in cipherTypes.keys {
            for mode in cipherTypes[category]!.keys {
                if (cipherType == cipherTypes[category]![mode]!) {
                    return (category, mode)
                }
            }
        }
        
        return (.RightCutter, .Normal)
    }
}

