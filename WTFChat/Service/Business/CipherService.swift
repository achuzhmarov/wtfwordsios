import Foundation

class CipherService: Service {
    private let ciphers: [CipherSettings] = [
            CipherSettings(type: .RightCutter, difficulty: .Easy, cipher: RightCutterEasyCipher()),
            CipherSettings(type: .RightCutter, difficulty: .Normal, cipher: RightCutterNormalCipher()),
            CipherSettings(type: .RightCutter, difficulty: .Hard, cipher: RightCutterHardCipher()),

            CipherSettings(type: .LeftCutter, difficulty: .Easy, cipher: LeftCutterEasyCipher()),
            CipherSettings(type: .LeftCutter, difficulty: .Normal, cipher: LeftCutterNormalCipher()),
            CipherSettings(type: .LeftCutter, difficulty: .Hard, cipher: LeftCutterHardCipher()),

            CipherSettings(type: .DoubleCutter, difficulty: .Easy, cipher: DoubleCutterEasyCipher()),
            CipherSettings(type: .DoubleCutter, difficulty: .Normal, cipher: DoubleCutterNormalCipher()),
            CipherSettings(type: .DoubleCutter, difficulty: .Hard, cipher: DoubleCutterHardCipher()),

            CipherSettings(type: .RandomCutter, difficulty: .Easy, cipher: RandomCutterEasyCipher()),
            CipherSettings(type: .RandomCutter, difficulty: .Normal, cipher: RandomCutterNormalCipher()),
            CipherSettings(type: .RandomCutter, difficulty: .Hard, cipher: RandomCutterHardCipher()),

            CipherSettings(type: .Shuffle, difficulty: .Easy, cipher: ShuffleEasyCipher()),
            CipherSettings(type: .Shuffle, difficulty: .Normal, cipher: ShuffleNormalCipher()),
            CipherSettings(type: .Shuffle, difficulty: .Hard, cipher: ShuffleHardCipher())
    ]

    func cipherMessage(message: Message) {
        for word in message.words! {
            if (word.type == WordType.New) {
                word.cipheredText = cipherText(message.cipherType, difficulty: message.cipherDifficulty, word: word)
            }
        }
    }

    private func cipherText(type: CipherType, difficulty: CipherDifficulty, word: Word) -> String {
        let cipher = getCipher(type, difficulty: difficulty)!
        return cipher.getTextForDecipher(word)
    }

    private func getCipher(type: CipherType, difficulty: CipherDifficulty) -> Cipher? {
        for cipherData in ciphers {
            if (cipherData.type == type && cipherData.difficulty == difficulty) {
                return cipherData.cipher
            }
        }

        return nil
    }
}

