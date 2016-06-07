import Foundation
import CoreData

class CoreSingleMessage: NSManagedObject {

    func updateFromMessageWithoutWords(message: SingleMessage) {
        self.timestamp = message.timestamp
        self.lastUpdate = message.lastUpdate
        self.deciphered = message.deciphered
        self.cipherType = message.cipherType.rawValue
        self.cipherDifficulty = message.cipherDifficulty.rawValue
        self.exp = message.exp
        self.extId = message.extId
        self.timerSecs = message.timerSecs
        self.hintsUsed = message.hintsUsed
    }

    func getMessage() -> SingleMessage? {
        if  (
                self.timestamp == nil ||
                self.lastUpdate == nil ||
                self.deciphered == nil ||
                self.cipherType == nil ||
                self.cipherDifficulty == nil ||
                self.exp == nil ||
                self.extId == nil ||
                self.timerSecs == nil ||
                self.hintsUsed == nil ||
                self.words == nil
            )
        {

            return nil
        }

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
            hintsUsed: Int(self.hintsUsed!)
        )

        return message
    }
}
