import Foundation

class SingleMessage: Message {
    private var coreSingleMessage: CoreSingleMessage!
    var level: Level!

    init(message: Message) {
        super.init(
            extId: message.extId,
            cipherType: message.cipherType,
            cipherDifficulty: message.cipherDifficulty,
            words: message.words

            /*deciphered: message.deciphered,
            timestamp: message.timestamp,
            lastUpdate: message.lastUpdate,
            exp: message.exp,
            timerSecs: message.timerSecs,
            hintsUsed: message.hintsUsed*/
        )
    }

    init(extId: String, cipherType: CipherType, cipherDifficulty: CipherDifficulty, words: [Word],
            deciphered: Bool, timestamp: NSDate, lastUpdate: NSDate, exp: Int, timerSecs: Int, hintsUsed: Int,
            coreSingleMessage: CoreSingleMessage) {

        super.init(
            extId: extId,
            cipherType: cipherType,
            cipherDifficulty: cipherDifficulty,
            words: words,
            deciphered: deciphered,
            timestamp: timestamp,
            lastUpdate: lastUpdate,
            exp: exp,
            timerSecs: timerSecs,
            hintsUsed: hintsUsed
        )

        self.coreSingleMessage = coreSingleMessage
    }

    func setCoreSingleMessage(coreSingleMessage: CoreSingleMessage) {
        self.coreSingleMessage = coreSingleMessage
    }

    func getCoreSingleMessage() -> CoreSingleMessage {
        return coreSingleMessage
    }
}
