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
    
    case EasyDoubleCutter
    case NormalDoubleCutter
    case HardDoubleCutter
    
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
        
        .EasyDoubleCutter: EasyDoubleCutterCipher(),
        .NormalDoubleCutter: NormalDoubleCutterCipher(),
        .HardDoubleCutter: HardDoubleCutterCipher(),
    
        .EasyRandomCutter: EasyRandomCutterCipher(),
        .NormalRandomCutter: NormalRandomCutterCipher(),
        .HardRandomCutter: HardRandomCutterCipher(),
    
        .ShuffleExceptFirstLetter: ShuffleExceptFirstLetterCipher(),
        .ShuffleFullWord: ShuffleFullWordCipher(),
        .ShuffleWithExtraLetter: ShuffleWithExtraLetterCipher()
    ]
    
    static let cipherLvls: [CipherType: Int] = [
        .HalfWordRoundUp: 0,
        .HalfWordRoundDown: 0,
        .FirstLetter: 0,
        
        .ExceptTwoLettersFromEnd: 5,
        .HalfWordRoundDownFromEnd: 8,
        .HalfWordPlusOneFromEnd: 12,
        
        .EasyDoubleCutter: 15,
        .NormalDoubleCutter: 18,
        .HardDoubleCutter: 22,
        
        .EasyRandomCutter: 25,
        .NormalRandomCutter: 28,
        .HardRandomCutter: 32,
        
        .ShuffleExceptFirstLetter: 35,
        .ShuffleFullWord: 38,
        .ShuffleWithExtraLetter: 42
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
            .Easy: .EasyDoubleCutter,
            .Normal: .NormalDoubleCutter,
            .Hard: .HardDoubleCutter
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
    
    static let cipherCategoryPurchases: [CipherCategory: ProductIdentifier] = [
        .RightCutter: "",
        .LeftCutter: IAPProducts.CIPHER_LEFT_CUTTER,
        .DoubleCutter: IAPProducts.CIPHER_DOUBLE_CUTTER,
        .RandomCutter: IAPProducts.CIPHER_RANDOM_CUTTER,
        .Shuffle: IAPProducts.CIPHER_SHUFFLE
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
    
    class func getProductId(category: CipherCategory) -> ProductIdentifier? {
        return cipherCategoryPurchases[category]
    }
    
    class func getCipherCategory(productId: ProductIdentifier) -> CipherCategory? {
        for category in cipherCategoryPurchases.keys {
            if (productId == cipherCategoryPurchases[category]!) {
                return category
            }
        }
        
        return nil
    }
    
    class func getCipherLvl(category: CipherCategory, mode: CipherMode) -> Int? {
        let cipherType = getCipherType(category, mode: mode)
        return getCipherLvl(cipherType)
    }
    
    class func getCipherLvl(cipherType: CipherType) -> Int? {
        return cipherLvls[cipherType]
    }
}

