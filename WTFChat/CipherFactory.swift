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
}

enum CipherType : Int {
    case HalfWordRoundUp = 1
    case HalfWordRoundDown
    case FirstLetter

    case ExceptTwoLettersFromEnd
    case HalfWordRoundDownFromEnd
    case HalfWordPlusOneFromEnd
    
    case ShuffleExceptFirstLetter
    case ShuffleFullWord
    case ShuffleWithExtraLetter
    
    case OneLetterFromBothEnds
    case TwoLettersFromBothEnds
    case ThreeLettersFromBothEnds
    
    case EasyRandomCutter
    case NormalRandomCutter
    case HardRandomCutter
}

enum CipherCategory : Int, CustomStringConvertible {
    case RightCutter = 0
    case LeftCutter
    case DoubleCutter
    case RandomCutter
    case Shuffle
    
    var description : String {
        get {
            switch self {
            case CipherCategory.RightCutter:
                return "Right Cutter"
            case CipherCategory.LeftCutter:
                return "Left Cutter"
            case CipherCategory.DoubleCutter:
                return "Double Cutter"
            case CipherCategory.RandomCutter:
                return "Random Cutter"
            case CipherCategory.Shuffle:
                return "Shuffle"
            }
        }
    }
}

enum CipherMode : Int, CustomStringConvertible {
    case Easy = 0
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
        
        .ExceptTwoLettersFromEnd: ExceptTwoLettersFromEndCipher(),
        .HalfWordRoundDownFromEnd: HalfWordRoundDownFromEndCipher(),
        .HalfWordPlusOneFromEnd: HalfWordPlusOneFromEndCipher(),
        
        .OneLetterFromBothEnds: OneLetterFromBothEndsCipher(),
        .TwoLettersFromBothEnds: TwoLettersFromBothEndsCipher(),
        .ThreeLettersFromBothEnds: ThreeLettersFromBothEndsCipher(),
    
        .EasyRandomCutter: EasyRandomCutterCipher(),
        .NormalRandomCutter: NormalRandomCutterCipher(),
        .HardRandomCutter: HardRandomCutterCipher(),
    
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
            .Easy: .ExceptTwoLettersFromEnd,
            .Normal: .HalfWordRoundDownFromEnd,
            .Hard: .HalfWordPlusOneFromEnd
        ],
        .DoubleCutter: [
            .Easy: .OneLetterFromBothEnds,
            .Normal: .TwoLettersFromBothEnds,
            .Hard: .ThreeLettersFromBothEnds
        ],
        .RandomCutter: [
            .Easy: .EasyRandomCutter,
            .Normal: .NormalRandomCutter,
            .Hard: .HardRandomCutter
        ],
        .Shuffle: [
            .Easy: .ShuffleExceptFirstLetter,
            .Normal: .ShuffleFullWord,
            .Hard: .ShuffleWithExtraLetter
        ]
        
    ]
    
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
    
    class func getAllCategories() -> [CipherCategory] {
        return [.RightCutter, .LeftCutter, .DoubleCutter, .RandomCutter, .Shuffle]
    }
    
    class func getAllModes() -> [CipherMode] {
        return [.Easy, .Normal, .Hard]
    }
}

