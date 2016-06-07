import Foundation

class RemoteMessage: Message {
    var id: String = ""
    var talkId: String
    var author: String
    var isLocal: Bool = false

    init(baseMessage: Message, talkId: String, author: String) {
        self.talkId = talkId
        self.author = author

        super.init(
            extId: baseMessage.extId,
            cipherType: baseMessage.cipherType,
            cipherDifficulty: baseMessage.cipherDifficulty,
            words: baseMessage.words
        )
    }

    init(id: String, talkId: String, author: String, words: [Word], deciphered: Bool, cipherType: CipherType,
         cipherDifficulty: CipherDifficulty, timestamp: NSDate, lastUpdate: NSDate, exp: Int, extId: String,
         timerSecs: Int, hintsUsed: Int, isLocal: Bool) {

        self.id = id;
        self.talkId = talkId
        self.author = author
        self.isLocal = isLocal

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
    }
}
