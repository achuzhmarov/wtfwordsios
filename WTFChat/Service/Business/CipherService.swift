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

