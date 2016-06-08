import Foundation

class SingleTalk: Talk {
    var cipherType: CipherType
    var cipherDifficulty: CipherDifficulty
    var wins = 0

    private var coreSingleTalk: CoreSingleTalk!

    var cipherSettings: CipherSettings?

    init(cipherType: CipherType, cipherDifficulty: CipherDifficulty, wins: Int = 0, messages: [Message] = [Message]()) {
        self.cipherType = cipherType
        self.cipherDifficulty = cipherDifficulty
        self.wins = wins

        super.init(messages: messages)
    }

    func appendMessage(message: SingleMessage) {
        messages.append(message)
        coreSingleTalk.addMessagesObject(message.getCoreSingleMessage())
    }

    func setCoreSingleTalk(coreSingleTalk: CoreSingleTalk) {
        self.coreSingleTalk = coreSingleTalk
    }

    func updateCoreSingleTalk() {
        self.coreSingleTalk.updateFromTalkWithoutMessages(self)
    }
}
