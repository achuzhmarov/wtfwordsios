import Foundation

class SingleTalk: Talk {
    var cipherType: CipherType

    init(cipherType: CipherType, messages: [Message] = [Message]()) {
        self.cipherType = cipherType

        super.init(messages: messages)
    }
}
