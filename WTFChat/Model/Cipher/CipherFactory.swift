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

enum CipherType : Int, CustomStringConvertible {
    case RightCutter = 0
    case LeftCutter
    case DoubleCutter
    case RandomCutter
    case Shuffle
    
    var description : String {
        get {
            switch self {
            case CipherType.RightCutter:
                return "Right Cutter"
            case CipherType.LeftCutter:
                return "Left Cutter"
            case CipherType.DoubleCutter:
                return "Double Cutter"
            case CipherType.RandomCutter:
                return "Random Cutter"
            case CipherType.Shuffle:
                return "Shuffle"
            }
        }
    }
}

enum CipherDifficulty : Int, CustomStringConvertible {
    case Easy = 0
    case Normal
    case Hard
    
    var description : String {
        get {
            switch self {
            case CipherDifficulty.Easy:
                return "Easy"
            case CipherDifficulty.Normal:
                return "Normal"
            case CipherDifficulty.Hard:
                return "Hard"
            }
        }
    }
}

class CipherFactory {
    static let ciphers: [CipherData] = [
            CipherData(type: .RightCutter, difficulty: .Easy, maxStars: 10, cipher: RightCutterEasyCipher()),
            CipherData(type: .RightCutter, difficulty: .Normal, maxStars: 25, cipher: RightCutterNormalCipher()),
            CipherData(type: .RightCutter, difficulty: .Hard, maxStars: 50, cipher: RightCutterHardCipher()),

            CipherData(type: .LeftCutter, difficulty: .Easy, maxStars: 10, cipher: LeftCutterEasyCipher()),
            CipherData(type: .LeftCutter, difficulty: .Normal, maxStars: 25, cipher: LeftCutterNormalCipher()),
            CipherData(type: .LeftCutter, difficulty: .Hard, maxStars: 50, cipher: LeftCutterHardCipher()),

            CipherData(type: .DoubleCutter, difficulty: .Easy, maxStars: 10, cipher: DoubleCutterEasyCipher()),
            CipherData(type: .DoubleCutter, difficulty: .Normal, maxStars: 25, cipher: DoubleCutterNormalCipher()),
            CipherData(type: .DoubleCutter, difficulty: .Hard, maxStars: 50, cipher: DoubleCutterHardCipher()),

            CipherData(type: .RandomCutter, difficulty: .Easy, maxStars: 10, cipher: RandomCutterEasyCipher()),
            CipherData(type: .RandomCutter, difficulty: .Normal, maxStars: 25, cipher: RandomCutterNormalCipher()),
            CipherData(type: .RandomCutter, difficulty: .Hard, maxStars: 50, cipher: RandomCutterHardCipher()),

            CipherData(type: .Shuffle, difficulty: .Easy, maxStars: 10, cipher: ShuffleEasyCipher()),
            CipherData(type: .Shuffle, difficulty: .Normal, maxStars: 25, cipher: ShuffleNormalCipher()),
            CipherData(type: .Shuffle, difficulty: .Hard, maxStars: 50, cipher: ShuffleHardCipher())
    ]

    private class func getCipher(type: CipherType, difficulty: CipherDifficulty) -> Cipher? {
        for cipherData in ciphers {
            if (cipherData.type == type && cipherData.difficulty == difficulty) {
                return cipherData.cipher
            }
        }

        return nil
    }

    class func cipherText(type: CipherType, difficulty: CipherDifficulty, word: Word) -> String {
        return getCipher(type, difficulty: difficulty)!.getTextForDecipher(word)
    }
    
    class func getAllTypes() -> [CipherType] {
        return [.RightCutter, .LeftCutter, .DoubleCutter, .RandomCutter, .Shuffle]
    }
    
    class func getAllDifficulties() -> [CipherDifficulty] {
        return [.Easy, .Normal, .Hard]
    }
}

