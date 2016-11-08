import Foundation

class CoreMessageService: Service {
    fileprivate let CORE_MESSAGE_CLASS_NAME = "CoreMessage"

    fileprivate let coreDataService: CoreDataService

    init(coreDataService: CoreDataService) {
        self.coreDataService = coreDataService
    }

    func updateFromMessage(_ coreMessage: CoreMessage, message: RemoteMessage) {
        coreMessage.updateFromMessageWithoutWords(message)
        updateMessageWords(coreMessage, message: message)
    }

    fileprivate func updateMessageWords(_ coreMessage: CoreMessage, message: RemoteMessage) {
        //clear old words if any
        if let words = coreMessage.words {
            for _ in 0..<words.count {
                if let coreWord = words[0] as? CoreWord {
                    coreMessage.removeWordsObject(coreWord)
                    coreDataService.deleteObject(coreWord)
                }
            }
        }

        //add new words
        for domainWord in message.words {
            let newCoreWord = coreDataService.createObject(CORE_WORD_CLASS_NAME) as! CoreWord
            newCoreWord.updateFromWord(domainWord)
            coreMessage.addWordsObject(newCoreWord)
        }
    }

    func createOrUpdateMessage(_ message: RemoteMessage) {
        if getMessageByExtId(message) != nil {
            updateMessage(message)
        } else {
            createMessage(message)
        }
    }

    func createMessage(_ message: RemoteMessage) {
        let newCoreMessage = coreDataService.createObject(CORE_MESSAGE_CLASS_NAME) as! CoreMessage
        updateFromMessage(newCoreMessage, message: message)
        coreDataService.saveContext()
    }

    func getAllWaiting() -> [RemoteMessage] {
        let predicate = NSPredicate(format: "talkId != %@", "0")
        return getByPredicate(predicate)
    }

    func getAllLocal() -> [RemoteMessage] {
        let predicate = NSPredicate(format: "talkId == %@", "0")
        return getByPredicate(predicate)
    }

    func getByTalkId(_ talkId: String) -> [RemoteMessage] {
        let predicate = NSPredicate(format: "talkId == %@", talkId)
        return getByPredicate(predicate)
    }

    func getMessageByExtId(_ message: RemoteMessage) -> RemoteMessage? {
        let fetchRequest = coreDataService.createFetch(CORE_MESSAGE_CLASS_NAME)

        let predicate = NSPredicate(format: "extId == %@", message.extId)
        fetchRequest.predicate = predicate

        let results = coreDataService.executeFetch(fetchRequest)

        if (results.count > 0) {
            if let coreMessage = results[0] as? CoreMessage {
                return coreMessage.getMessage()
            }
        }

        return nil
    }

    fileprivate func getByPredicate(_ predicate: NSPredicate) -> [RemoteMessage] {
        let fetchRequest = coreDataService.createFetch(CORE_MESSAGE_CLASS_NAME)

        let sortDescriptor = NSSortDescriptor(key: "timestamp", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]

        fetchRequest.predicate = predicate

        let results = coreDataService.executeFetch(fetchRequest)

        var domainMessages = [RemoteMessage]()

        for item in results {
            if let coreMessage = item as? CoreMessage {
                if let domainMessage = coreMessage.getMessage() {
                    domainMessages.append(domainMessage)
                }
            }
        }

        return domainMessages
    }

    func updateMessage(_ message: RemoteMessage) {
        let fetchRequest = coreDataService.createFetch(CORE_MESSAGE_CLASS_NAME)

        let predicate = NSPredicate(format: "extId == %@", message.extId)
        fetchRequest.predicate = predicate

        let results = coreDataService.executeFetch(fetchRequest)

        if (results.count > 0) {
            if let coreMessage = results[0] as? CoreMessage {
                updateFromMessage(coreMessage, message: message)
                coreDataService.saveContext()
            }
        }
    }

    func deleteMessageIfExists(_ message: RemoteMessage) {
        if getMessageByExtId(message) != nil {
            deleteMessage(message)
        } else {
            //do nothing
        }
    }

    func deleteMessage(_ message: RemoteMessage) {
        let fetchRequest = coreDataService.createFetch(CORE_MESSAGE_CLASS_NAME)

        let predicate = NSPredicate(format: "extId == %@", message.extId)
        fetchRequest.predicate = predicate

        let results = coreDataService.executeFetch(fetchRequest)

        if (results.count > 0) {
            if let coreMessage = results[0] as? CoreMessage {
                coreDataService.deleteObject(coreMessage)
            }
        }
    }
}
