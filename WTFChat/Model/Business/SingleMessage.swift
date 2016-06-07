import Foundation

class SingleMessage: Message {
    private var coreSingleMessage: CoreSingleMessage!

    func setCoreSingleMessage(coreSingleMessage: CoreSingleMessage) {
        self.coreSingleMessage = coreSingleMessage
    }

    func getCoreSingleMessage() -> CoreSingleMessage {
        return coreSingleMessage
    }
}
