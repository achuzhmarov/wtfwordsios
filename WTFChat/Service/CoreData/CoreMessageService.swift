//
// Created by Artem Chuzhmarov on 31/05/16.
// Copyright (c) 2016 Artem Chuzhmarov. All rights reserved.
//

import Foundation

class CoreMessageService {
    private let coreDataService: CoreDataService

    init(coreDataService: CoreDataService) {
        self.coreDataService = coreDataService
    }

    func updateFromMessage(coreMessage: CoreMessage, message: Message) {
        coreMessage.updateFromMessageWithoutWords(message)
        updateMessageWords(coreMessage, message: message)
    }

    private func updateMessageWords(coreMessage: CoreMessage, message: Message) {
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

    func createOrUpdateMessage(message: Message) {
        if getMessageByExtId(message) != nil {
            updateMessage(message)
        } else {
            createMessage(message)
        }
    }

    func createMessage(message: Message) {
        let newCoreMessage = coreDataService.createObject(CORE_MESSAGE_CLASS_NAME) as! CoreMessage
        updateFromMessage(newCoreMessage, message: message)
        coreDataService.saveContext()
    }

    func getAllWaiting() -> [Message] {
        let predicate = NSPredicate(format: "talkId != %@", "0")
        return getByPredicate(predicate)
    }

    func getAllLocal() -> [Message] {
        let predicate = NSPredicate(format: "talkId == %@", "0")
        return getByPredicate(predicate)
    }

    func getByTalkId(talkId: String) -> [Message] {
        let predicate = NSPredicate(format: "talkId == %@", talkId)
        return getByPredicate(predicate)
    }

    func getMessageByExtId(message: Message) -> Message? {
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

    private func getByPredicate(predicate: NSPredicate) -> [Message] {
        let fetchRequest = coreDataService.createFetch(CORE_MESSAGE_CLASS_NAME)

        let sortDescriptor = NSSortDescriptor(key: "timestamp", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]

        fetchRequest.predicate = predicate

        let results = coreDataService.executeFetch(fetchRequest)

        var domainMessages = [Message]()

        for item in results {
            if let coreMessage = item as? CoreMessage {
                if let domainMessage = coreMessage.getMessage() {
                    domainMessages.append(domainMessage)
                }
            }
        }

        return domainMessages
    }

    func updateMessage(message: Message) {
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

    func deleteMessageIfExists(message: Message) {
        if getMessageByExtId(message) != nil {
            deleteMessage(message)
        } else {
            //do nothing
        }
    }

    func deleteMessage(message: Message) {
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
