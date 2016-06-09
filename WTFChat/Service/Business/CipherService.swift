import Foundation

class CipherService: Service {
    private let ciphers: [CipherSettings] = [
            CipherSettings(type: .RightCutter, difficulty: .Easy, maxStars: 5, cipher: RightCutterEasyCipher()),
            CipherSettings(type: .RightCutter, difficulty: .Normal, maxStars: 10, cipher: RightCutterNormalCipher()),
            CipherSettings(type: .RightCutter, difficulty: .Hard, maxStars: 10, cipher: RightCutterHardCipher()),

            CipherSettings(type: .LeftCutter, difficulty: .Easy, maxStars: 5, cipher: LeftCutterEasyCipher()),
            CipherSettings(type: .LeftCutter, difficulty: .Normal, maxStars: 10, cipher: LeftCutterNormalCipher()),
            CipherSettings(type: .LeftCutter, difficulty: .Hard, maxStars: 10, cipher: LeftCutterHardCipher()),

            CipherSettings(type: .DoubleCutter, difficulty: .Easy, maxStars: 5, cipher: DoubleCutterEasyCipher()),
            CipherSettings(type: .DoubleCutter, difficulty: .Normal, maxStars: 15, cipher: DoubleCutterNormalCipher()),
            CipherSettings(type: .DoubleCutter, difficulty: .Hard, maxStars: 20, cipher: DoubleCutterHardCipher()),

            CipherSettings(type: .RandomCutter, difficulty: .Easy, maxStars: 5, cipher: RandomCutterEasyCipher()),
            CipherSettings(type: .RandomCutter, difficulty: .Normal, maxStars: 20, cipher: RandomCutterNormalCipher()),
            CipherSettings(type: .RandomCutter, difficulty: .Hard, maxStars: 30, cipher: RandomCutterHardCipher()),

            CipherSettings(type: .Shuffle, difficulty: .Easy, maxStars: 5, cipher: ShuffleEasyCipher()),
            CipherSettings(type: .Shuffle, difficulty: .Normal, maxStars: 20, cipher: ShuffleNormalCipher()),
            CipherSettings(type: .Shuffle, difficulty: .Hard, maxStars: 30, cipher: ShuffleHardCipher())
    ]

    func cipherMessage(message: Message) {
        for word in message.words! {
            if (word.type == WordType.New) {
                word.cipheredText = cipherText(message.cipherType, difficulty: message.cipherDifficulty, word: word)
            }
        }
    }

    func getCipherSettings(type: CipherType, difficulty: CipherDifficulty) -> CipherSettings? {
        for cipherData in ciphers {
            if (cipherData.type == type && cipherData.difficulty == difficulty) {
                return cipherData
            }
        }

        return nil
    }

    private func cipherText(type: CipherType, difficulty: CipherDifficulty, word: Word) -> String {
        return getCipherSettings(type, difficulty: difficulty)!.cipher.getTextForDecipher(word)
    }
}

