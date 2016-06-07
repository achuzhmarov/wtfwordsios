import Foundation

class SingleTalk {
    let cipherType: CipherType
    let cipherDifficulty: CipherDifficulty
    var wins = 0
    var messages = [Message]()

    var cipherSettings: CipherSettings?

    init(cipherType: CipherType, cipherDifficulty: CipherDifficulty) {
        self.cipherType = cipherType
        self.cipherDifficulty = cipherDifficulty
    }

    func appendMessage(message: Message) {
        messages.append(message)
    }
}
