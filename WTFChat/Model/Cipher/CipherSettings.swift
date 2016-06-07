import Foundation

class CipherSettings {
    var type: CipherType
    var difficulty: CipherDifficulty
    var maxStars: Int
    var cipher: Cipher

    init(type: CipherType, difficulty: CipherDifficulty, maxStars: Int, cipher: Cipher) {
        self.type = type
        self.difficulty = difficulty
        self.maxStars = maxStars
        self.cipher = cipher
    }
}
