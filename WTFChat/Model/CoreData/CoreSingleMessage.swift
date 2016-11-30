import Foundation
import CoreData

class CoreSingleMessage: NSManagedObject {

    func updateFromMessageWithoutWords(_ message: SingleMessage) {
        self.timestamp = message.timestamp
        self.lastUpdate = message.lastUpdate
        self.deciphered = message.deciphered as NSNumber?
        self.cipherType = message.cipherType.rawValue as NSNumber?
        self.cipherDifficulty = message.cipherDifficulty.rawValue as NSNumber?
        self.exp = message.exp as NSNumber?
        self.extId = message.extId
        self.timerSecs = message.timerSecs as NSNumber?
        self.hintsUsed = message.wtfUsed as NSNumber?
    }

    func getSingleMessage() -> SingleMessage? {
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

        let message = SingleMessage(
            extId: self.extId!,
            cipherType: enumCipherType!,
            cipherDifficulty: enumCipherDifficulty!,
            words: domainWords,
            deciphered: Bool(self.deciphered!),
            timestamp: self.timestamp!,
            lastUpdate: self.lastUpdate!,
            exp: Int(self.exp!),
            timerSecs: Int(self.timerSecs!),
            hintsUsed: Int(self.hintsUsed!),
            coreSingleMessage: self
        )

        return message
    }
}
