import Foundation

let CORE_WORD_CLASS_NAME = "CoreWord"

class CoreSingleMessageService {
    private let CORE_SINGLE_MESSAGE_CLASS_NAME = "CoreSingleMessage"

    private let coreDataService: CoreDataService

    func updateMessage(message: SingleMessage) {
        updateFromMessage(message.getCoreSingleMessage(), message: message)
        coreDataService.saveContext()
    }

    func createMessage(singleTalk: SingleTalk, message: SingleMessage) {
        let newCoreSingleMessage = coreDataService.createObject(CORE_SINGLE_MESSAGE_CLASS_NAME) as! CoreSingleMessage
        updateFromMessage(newCoreSingleMessage, message: message)
        coreDataService.saveContext()
    }

    private func updateFromMessage(coreSingleMessage: CoreSingleMessage, message: SingleMessage) {
        coreSingleMessage.updateFromMessageWithoutWords(message)
        updateMessageWords(message.getCoreSingleMessage(), message: message)
    }

    private func updateMessageWords(coreSingleMessage: CoreSingleMessage, message: SingleMessage) {
        //clear old words if any
        if let words = coreSingleMessage.words {
            for _ in 0..<words.count {
                if let coreWord = words[0] as? CoreWord {
                    coreSingleMessage.removeWordsObject(coreWord)
                    coreDataService.deleteObject(coreWord)
                }
            }
        }

        //add new words
        for domainWord in message.words {
            let newCoreWord = coreDataService.createObject(CORE_WORD_CLASS_NAME) as! CoreWord
            newCoreWord.updateFromWord(domainWord)
            coreSingleMessage.addWordsObject(newCoreWord)
        }
    }
}
