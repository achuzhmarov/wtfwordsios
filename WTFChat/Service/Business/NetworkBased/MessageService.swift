//
//  MessageService.swift
//  WTFChat
//
//  Created by Artem Chuzhmarov on 08/11/15.
//  Copyright © 2015 Artem Chuzhmarov. All rights reserved.
//

import Foundation

protocol MessageListener: class {
    func updateMessages(talk: Talk?, wasNew: Bool, error: NSError?)
    func messageSended(talk: Talk?, error: NSError?)
    func loadEarlierCompleteHandler(talk: Talk?, newMessagesCount: Int, error: NSError?)
}

struct WeakListener {
    weak var listener: MessageListener?
    
    init(listener: MessageListener) {
        self.listener = listener
    }
}

class MessageService: NSObject {
    private let MESSAGES_UPDATE_TIMER_INTERVAL = 10.0

    private let messageNetworkService: MessageNetworkService
    private let talkService: TalkService
    
    var listeners = [String: WeakListener]()
    var talksToUpdate = Set<String>()
    
    var updateTimer: NSTimer?

    init(messageNetworkService: MessageNetworkService, talkService: TalkService) {
        self.messageNetworkService = messageNetworkService
        self.talkService = talkService
    }

    func startUpdateTimer() {
        dispatch_async(dispatch_get_main_queue(), {
            self.updateTimer?.invalidate()
            
            self.updateTimer = NSTimer.scheduledTimerWithTimeInterval(self.MESSAGES_UPDATE_TIMER_INTERVAL, target: self,
                selector: #selector(MessageService.updateMessages as (MessageService) -> () -> ()), userInfo: nil, repeats: true)
        })
    }
    
    func clear() {
        self.updateTimer?.invalidate()
        self.listeners = [String: WeakListener]()
        self.talksToUpdate = Set<String>()
    }
    
    func removeListener(talk: Talk) {
        listeners[talk.id] = nil
    }
    
    func initMessageListener(talk: Talk, listener: MessageListener) {
        listeners[talk.id] = WeakListener(listener: listener)
        talksToUpdate.insert(talk.id)
        
        if (talk.messages.count == 0) {
            getInitialMessagesForTalk(talk, listener: listener)
        }
    }

    func fireMessagesUpdate(talkId: String) {
        if (talksToUpdate.contains(talkId)) {
            updateMessages(talkId)
        }
    }
    
    //for timer
    func updateMessages() {
        sendLocalMessages()
        
        for talkId in talksToUpdate {
            updateMessages(talkId)
        }
    }
    
    private func sendLocalMessages() {
        let messages = CoreMessage.getAllWaiting()
        
        for message in messages {
            if (message.id == "") {
                createMessage(message)
            } else {
                decipherMessage(message)
            }
        }
    }
    
    func updateMessages(talkId: String) {
        let talk = talkService.getByTalkId(talkId)!
        let lastUpdate = getMessagesLastUpdate(talk)
        let listener = listeners[talkId]?.listener
        
        if (talk.messages.count == 0) {
            getInitialMessagesForTalk(talk, listener: listener)
        } else {
            messageNetworkService.getUnreadMessagesByTalk(talk, lastUpdate: lastUpdate) { (messages, error) -> Void in
                dispatch_async(dispatch_get_main_queue(), {
                    if let requestError = error {
                        listener?.updateMessages(nil, wasNew: false, error: requestError)
                    } else {
                        if let newMessages = messages {
                            var wasNew = false
                            
                            for message in newMessages {
                                let isNew = self.updateOrCreateMessageInArray(talk, message: message)
                                wasNew = wasNew || isNew
                            }
                            
                            self.talkService.updateTalkInArray(talk, withMessages: true)
                            
                            listener?.updateMessages(talk, wasNew: wasNew, error: nil)
                        }
                    }
                })
            }
        }
    }
    
    private func getInitialMessagesForTalk(talk: Talk, listener: MessageListener?) {
        messageNetworkService.getMessagesByTalk(talk) { (messages, error) -> Void in
            dispatch_async(dispatch_get_main_queue(), {
                if let requestError = error {
                    listener?.updateMessages(nil, wasNew: false, error: requestError)
                } else {
                    talk.messages = messages!
                    self.talkService.updateTalkInArray(talk, withMessages: true)
                    
                    listener?.updateMessages(talk, wasNew: true, error: nil)
                }
            })
        }
    }
    
    func loadEarlier(talkId: String) {
        let talk = talkService.getByTalkId(talkId)!
        let listener = listeners[talkId]?.listener
        
        messageNetworkService.getEarlierMessagesByTalk(talk, skip: talk.messages.count) { (messages, error) -> Void in
            dispatch_async(dispatch_get_main_queue(), {
                if let requestError = error {
                    listener?.loadEarlierCompleteHandler(nil, newMessagesCount: 0, error: requestError)
                } else {
                    if let newMessages = messages {
                        for message in newMessages {
                            self.updateOrCreateMessageInArray(talk, message: message)
                        }
                        
                        self.talkService.updateTalkInArray(talk, withMessages: true)
                        
                        listener?.loadEarlierCompleteHandler(talk, newMessagesCount: newMessages.count, error: nil)
                    }
                }
            })
        }
    }
    
    func createMessage(newMessage: Message) {
        let talk = talkService.getByTalkId(newMessage.talkId)!
        let listener = listeners[talk.id]?.listener
        
        messageNetworkService.saveMessage(newMessage) { (message, error) -> Void in
            dispatch_async(dispatch_get_main_queue(), {
                if let requestError = error {
                    listener?.messageSended(nil, error: requestError)
                    
                    //save message in localStore
                    CoreMessage.createOrUpdateMessage(newMessage)
                } else {
                    CoreMessage.deleteMessageIfExists(newMessage)
                    
                    if let responseMessage = message {
                        self.updateOrCreateMessageInArray(talk, message: responseMessage)
                        self.talkService.updateTalkInArray(talk, withMessages: true)
                        
                        listener?.messageSended(talk, error: nil)
                    }
                }
            })
        }
    }
    
    func decipherMessage(decipheredMessage: Message, completion:((message: Message?, error: NSError?) -> Void)? = nil) {
        messageNetworkService.decipherMessage(decipheredMessage){ (message, error) -> Void in
            dispatch_async(dispatch_get_main_queue(), {
                if error != nil {
                    //save message in localStore
                    CoreMessage.createOrUpdateMessage(decipheredMessage)
                } else {
                    CoreMessage.deleteMessageIfExists(decipheredMessage)
                }
                
                completion?(message: message, error: error)
            })
        }
    }
    
    func updateMessageInTalk(message: Message) {
        let talk = talkService.getByTalkId(message.talkId)!
        updateOrCreateMessageInArray(talk, message: message)
        talkService.updateTalkInArray(talk, withMessages: true)
    }
    
    func markTalkAsReaded(talk: Talk) {
        messageNetworkService.markTalkAsReaded(talk) { (error) -> Void in
            if let requestError = error {
                print(requestError)
            } else {
                //do nothing
            }
        }
    }
    
    private func getMessagesLastUpdate(talk: Talk) -> NSDate {
        var lastUpdate: NSDate?
        
        for message in talk.messages {
            //ignore local messages
            if (message.isLocal) {
                continue
            }
            
            if (lastUpdate == nil || message.lastUpdate.isGreater(lastUpdate!)) {
                lastUpdate = message.lastUpdate
            }
        }
        
        if (lastUpdate != nil) {
            return lastUpdate!
        } else {
            return NSDate.defaultPast()
        }
    }
    
    private func updateOrCreateMessageInArray(talk: Talk, message: Message) -> Bool {
        for i in 0..<talk.messages.count {
            let sameId = (message.id != "" && (message.id == talk.messages[i].id))
            let wasSendedLocal = (message.extId != "" && (message.extId == talk.messages[i].extId))
            
            if  (sameId || wasSendedLocal) {
                talk.messages[i] = message
                return false
            }
        }
        
        talk.messages.append(message)
        return true
    }
}