import Foundation

class CipherSettings {
    var type: CipherType
    var difficulty: CipherDifficulty
    var cipher: Cipher

    init(type: CipherType, difficulty: CipherDifficulty, cipher: Cipher) {
        self.type = type
        self.difficulty = difficulty
        self.cipher = cipher
    }
}
