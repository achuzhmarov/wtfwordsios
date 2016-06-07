import Foundation
import CoreData

class CoreMessage: NSManagedObject {
    
    func updateFromMessageWithoutWords(message: RemoteMessage) {
        self.id = message.id
        self.timestamp = message.timestamp
        self.lastUpdate = message.lastUpdate
        self.talkId = message.talkId
        self.author = message.author
        self.deciphered = message.deciphered
        self.cipherType = message.cipherType.rawValue
        self.cipherDifficulty = message.cipherDifficulty.rawValue
        self.exp = message.exp
        self.isLocal = message.isLocal
        self.extId = message.extId
        self.timerSecs = message.timerSecs
        self.hintsUsed = message.hintsUsed
    }
    
    func getMessage() -> RemoteMessage? {
        var domainWords = [Word]()

        for item in self.words! {
            if let coreWord = item as? CoreWord {
                if let domainWord = coreWord.getWord() {
                    domainWords.append(domainWord)
                }
            }
        }

        let enumCipherType = CipherType(rawValue: Int(self.cipherType!))
        let enumCipherDifficulty = CipherDifficulty(rawValue: Int(self.cipherDifficulty!))

        let message = RemoteMessage(
            id: self.id!,
            talkId: self.talkId!,
            author: self.author!,
            words: domainWords,
            deciphered: Bool(self.deciphered!),
            cipherType: enumCipherType!,
            cipherDifficulty: enumCipherDifficulty!,
            timestamp: self.timestamp!,
            lastUpdate: self.lastUpdate!,
            exp: Int(self.exp!),
            extId: self.extId!,
            timerSecs: Int(self.timerSecs!),
            hintsUsed: Int(self.hintsUsed!),
            isLocal: Bool(self.isLocal!)
        )

        return message
    }
}
