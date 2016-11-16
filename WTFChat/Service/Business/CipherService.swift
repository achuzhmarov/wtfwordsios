import Foundation

class CipherService: Service {
    fileprivate let ciphers: [CipherSettings] = [
            CipherSettings(type: .rightCutter, difficulty: .easy, cipher: RightCutterEasyCipher()),
            CipherSettings(type: .rightCutter, difficulty: .normal, cipher: RightCutterNormalCipher()),
            CipherSettings(type: .rightCutter, difficulty: .hard, cipher: RightCutterHardCipher()),

            CipherSettings(type: .leftCutter, difficulty: .easy, cipher: LeftCutterEasyCipher()),
            CipherSettings(type: .leftCutter, difficulty: .normal, cipher: LeftCutterNormalCipher()),
            CipherSettings(type: .leftCutter, difficulty: .hard, cipher: LeftCutterHardCipher()),

            CipherSettings(type: .doubleCutter, difficulty: .easy, cipher: DoubleCutterEasyCipher()),
            CipherSettings(type: .doubleCutter, difficulty: .normal, cipher: DoubleCutterNormalCipher()),
            CipherSettings(type: .doubleCutter, difficulty: .hard, cipher: DoubleCutterHardCipher()),

            CipherSettings(type: .randomCutter, difficulty: .easy, cipher: RandomCutterEasyCipher()),
            CipherSettings(type: .randomCutter, difficulty: .normal, cipher: RandomCutterNormalCipher()),
            CipherSettings(type: .randomCutter, difficulty: .hard, cipher: RandomCutterHardCipher()),

            CipherSettings(type: .shuffle, difficulty: .easy, cipher: ShuffleEasyCipher()),
            CipherSettings(type: .shuffle, difficulty: .normal, cipher: ShuffleNormalCipher()),
            CipherSettings(type: .shuffle, difficulty: .hard, cipher: ShuffleHardCipher())
    ]

    func cipherMessage(_ message: Message) {
        for word in message.words! {
            if (word.type == WordType.new) {
                word.fullCipheredText = cipherText(message.cipherType, difficulty: message.cipherDifficulty, word: word)
            }
        }
    }

    fileprivate func cipherText(_ type: CipherType, difficulty: CipherDifficulty, word: Word) -> String {
        let cipher = getCipher(type, difficulty: difficulty)!
        return cipher.getTextForDecipher(word)
    }

    fileprivate func getCipher(_ type: CipherType, difficulty: CipherDifficulty) -> Cipher? {
        for cipherData in ciphers {
            if (cipherData.type == type && cipherData.difficulty == difficulty) {
                return cipherData.cipher
            }
        }

        return nil
    }
}

