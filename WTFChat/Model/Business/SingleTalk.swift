import Foundation

class SingleTalk {
    let cipherType: CipherType
    let cipherDifficulty: CipherDifficulty
    var wins = 0
    var messages = [Message]()

    private var coreSingleTalk: CoreSingleTalk!

    var cipherSettings: CipherSettings?

    init(cipherType: CipherType, cipherDifficulty: CipherDifficulty, wins: Int = 0, messages: [Message] = [Message]()) {
        self.cipherType = cipherType
        self.cipherDifficulty = cipherDifficulty
        self.wins = wins
        self.messages = messages
    }

    func appendMessage(message: Message) {
        messages.append(message)
    }

    func setCoreSingleTalk(coreSingleTalk: CoreSingleTalk) {
        self.coreSingleTalk = coreSingleTalk
    }

    func updateCoreSingleTalk() {
        self.coreSingleTalk.updateFromTalkWithoutMessages(self)
    }
}
