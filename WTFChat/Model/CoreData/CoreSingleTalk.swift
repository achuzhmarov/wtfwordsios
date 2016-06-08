import Foundation
import CoreData

class CoreSingleTalk: NSManagedObject {
    func updateFromTalkWithoutMessages(singleTalk: SingleTalk) {
        self.cipherType = singleTalk.cipherType.rawValue
        self.cipherDifficulty = singleTalk.cipherDifficulty.rawValue
        self.wins = singleTalk.wins
    }

    func getSingleTalk() -> SingleTalk? {
        let enumCipherType = CipherType(rawValue: Int(self.cipherType!))
        let enumCipherDifficulty = CipherDifficulty(rawValue: Int(self.cipherDifficulty!))

        let talk = SingleTalk(
            cipherType: enumCipherType!,
            cipherDifficulty: enumCipherDifficulty!,
            wins: Int(self.wins!)
        )

        var domainMessages = [SingleMessage]()

        for item in self.messages! {
            if let coreSingleMessage = item as? CoreSingleMessage {
                if let domainSingleMessage = coreSingleMessage.getSingleMessage() {
                    domainSingleMessage.singleTalk = talk
                    domainMessages.append(domainSingleMessage)
                }
            }
        }

        talk.messages = domainMessages
        talk.setCoreSingleTalk(self)

        return talk
    }
}
