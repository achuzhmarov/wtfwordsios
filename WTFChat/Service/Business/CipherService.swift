//
//  DecipherFactory.swift
//  WTFChat
//
//  Created by Artem Chuzhmarov on 12/09/15.
//  Copyright (c) 2015 Artem Chuzhmarov. All rights reserved.
//

import Foundation

class CipherService {
    private let ciphers: [CipherData] = [
            CipherData(type: .RightCutter, difficulty: .Easy, maxStars: 10, cipher: RightCutterEasyCipher(), wins: 10),
            CipherData(type: .RightCutter, difficulty: .Normal, maxStars: 10, cipher: RightCutterNormalCipher(), wins: 4),
            CipherData(type: .RightCutter, difficulty: .Hard, maxStars: 10, cipher: RightCutterHardCipher(), wins: 9),

            CipherData(type: .LeftCutter, difficulty: .Easy, maxStars: 10, cipher: LeftCutterEasyCipher(), wins: 0),
            CipherData(type: .LeftCutter, difficulty: .Normal, maxStars: 10, cipher: LeftCutterNormalCipher(), wins: 5),
            CipherData(type: .LeftCutter, difficulty: .Hard, maxStars: 10, cipher: LeftCutterHardCipher(), wins: 10),

            CipherData(type: .DoubleCutter, difficulty: .Easy, maxStars: 10, cipher: DoubleCutterEasyCipher(), wins: 1),
            CipherData(type: .DoubleCutter, difficulty: .Normal, maxStars: 10, cipher: DoubleCutterNormalCipher(), wins: 6),
            CipherData(type: .DoubleCutter, difficulty: .Hard, maxStars: 10, cipher: DoubleCutterHardCipher(), wins: 11),

            CipherData(type: .RandomCutter, difficulty: .Easy, maxStars: 10, cipher: RandomCutterEasyCipher(), wins: 2),
            CipherData(type: .RandomCutter, difficulty: .Normal, maxStars: 10, cipher: RandomCutterNormalCipher(), wins: 7),
            CipherData(type: .RandomCutter, difficulty: .Hard, maxStars: 10, cipher: RandomCutterHardCipher(), wins: 12),

            CipherData(type: .Shuffle, difficulty: .Easy, maxStars: 10, cipher: ShuffleEasyCipher(), wins: 3),
            CipherData(type: .Shuffle, difficulty: .Normal, maxStars: 10, cipher: ShuffleNormalCipher(), wins: 8),
            CipherData(type: .Shuffle, difficulty: .Hard, maxStars: 10, cipher: ShuffleHardCipher(), wins: 13)
    ]

    func getCipherData(type: CipherType, difficulty: CipherDifficulty) -> CipherData? {
        for cipherData in ciphers {
            if (cipherData.type == type && cipherData.difficulty == difficulty) {
                return cipherData
            }
        }

        return nil
    }

    func cipherMessage(message: Message) {
        for word in message.words! {
            if (word.wordType == WordType.New) {
                word.cipheredText = cipherText(message.cipherType, difficulty: message.cipherDifficulty, word: word)
            }
        }
    }

    private func cipherText(type: CipherType, difficulty: CipherDifficulty, word: Word) -> String {
        return getCipherData(type, difficulty: difficulty)!.cipher.getTextForDecipher(word)
    }
}

