//
//  MessageService.swift
//  WTFChat
//
//  Created by Artem Chuzhmarov on 08/11/15.
//  Copyright © 2015 Artem Chuzhmarov. All rights reserved.
//

import Foundation

protocol MessageListener: class {
    func updateMessages(_ talk: FriendTalk?, wasNew: Bool, error: NSError?)
    func messageSended(_ talk: FriendTalk?, error: NSError?)
    func loadEarlierCompleteHandler(_ talk: FriendTalk?, newMessagesCount: Int, error: NSError?)
}

struct WeakListener {
    weak var listener: MessageListener?
    
    init(listener: MessageListener) {
        self.listener = listener
    }
}

class MessageService: Service {
    fileprivate let MESSAGES_UPDATE_TIMER_INTERVAL = 10.0

    fileprivate let messageNetworkService: MessageNetworkService
    fileprivate let talkService: TalkService
    fileprivate let coreMessageService: CoreMessageService
    
    var listeners = [String: WeakListener]()
    var talksToUpdate = Set<String>()
    
    var updateTimer: Foundation.Timer?

    init(messageNetworkService: MessageNetworkService, talkService: TalkService, coreMessageService: CoreMessageService) {
        self.messageNetworkService = messageNetworkService
        self.talkService = talkService
        self.coreMessageService = coreMessageService
    }

    func startUpdateTimer() {
        DispatchQueue.main.async(execute: {
            self.updateTimer?.invalidate()
            
            self.updateTimer = Foundation.Timer.scheduledTimer(timeInterval: self.MESSAGES_UPDATE_TIMER_INTERVAL, target: self,
                selector: #selector(MessageService.updateMessages as (MessageService) -> () -> ()), userInfo: nil, repeats: true)
        })
    }
    
    func clear() {
        self.updateTimer?.invalidate()
        self.listeners = [String: WeakListener]()
        self.talksToUpdate = Set<String>()
    }
    
    func removeListener(_ talk: FriendTalk) {
        listeners[talk.id] = nil
    }
    
    func initMessageListener(_ talk: FriendTalk, listener: MessageListener) {
        listeners[talk.id] = WeakListener(listener: listener)
        talksToUpdate.insert(talk.id)
        
        if (talk.messages.count == 0) {
            getInitialMessagesForTalk(talk, listener: listener)
        }
    }

    func fireMessagesUpdate(_ talkId: String) {
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
    
    fileprivate func sendLocalMessages() {
        let messages = coreMessageService.getAllWaiting()
        
        for message in messages {
            if (message.id == "") {
                createMessage(message)
            } else {
                decipherMessage(message)
            }
        }
    }
    
    func updateMessages(_ talkId: String) {
        let talk = talkService.getByTalkId(talkId)!
        let lastUpdate = getMessagesLastUpdate(talk)
        let listener = listeners[talkId]?.listener
        
        if (talk.messages.count == 0) {
            getInitialMessagesForTalk(talk, listener: listener)
        } else {
            messageNetworkService.getUnreadMessagesByTalk(talk, lastUpdate: lastUpdate) { (messages, error) -> Void in
                DispatchQueue.main.async(execute: {
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
    
    fileprivate func getInitialMessagesForTalk(_ talk: FriendTalk, listener: MessageListener?) {
        messageNetworkService.getMessagesByTalk(talk) { (messages, error) -> Void in
            DispatchQueue.main.async(execute: {
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
    
    func loadEarlier(_ talkId: String) {
        let talk = talkService.getByTalkId(talkId)!
        let listener = listeners[talkId]?.listener
        
        messageNetworkService.getEarlierMessagesByTalk(talk, skip: talk.messages.count) { (messages, error) -> Void in
            DispatchQueue.main.async(execute: {
                if let requestError = error {
                    listener?.loadEarlierCompleteHandler(nil, newMessagesCount: 0, error: requestError)
                } else {
                    if let newMessages = messages {
                        for message in newMessages {
                            _ = self.updateOrCreateMessageInArray(talk, message: message)
                        }
                        
                        self.talkService.updateTalkInArray(talk, withMessages: true)
                        
                        listener?.loadEarlierCompleteHandler(talk, newMessagesCount: newMessages.count, error: nil)
                    }
                }
            })
        }
    }
    
    func createMessage(_ newMessage: RemoteMessage) {
        let talk = talkService.getByTalkId(newMessage.talkId)!
        let listener = listeners[talk.id]?.listener
        
        messageNetworkService.saveMessage(newMessage) { (message, error) -> Void in
            DispatchQueue.main.async(execute: {
                if let requestError = error {
                    listener?.messageSended(nil, error: requestError)
                    
                    //save message in localStore
                    self.coreMessageService.createOrUpdateMessage(newMessage)
                } else {
                    self.coreMessageService.deleteMessageIfExists(newMessage)
                    
                    if let responseMessage = message {
                        _ = self.updateOrCreateMessageInArray(talk, message: responseMessage)
                        self.talkService.updateTalkInArray(talk, withMessages: true)
                        
                        listener?.messageSended(talk, error: nil)
                    }
                }
            })
        }
    }
    
    func decipherMessage(_ decipheredMessage: RemoteMessage, completion:((_ message: RemoteMessage?, _ error: NSError?) -> Void)? = nil) {
        messageNetworkService.decipherMessage(decipheredMessage){ (message, error) -> Void in
            DispatchQueue.main.async(execute: {
                if error != nil {
                    //save message in localStore
                    self.coreMessageService.createOrUpdateMessage(decipheredMessage)
                } else {
                    self.coreMessageService.deleteMessageIfExists(decipheredMessage)
                }
                
                completion?(message, error)
            })
        }
    }
    
    func decipherMessageInTalk(_ message: RemoteMessage) {
        let talk = talkService.getByTalkId(message.talkId)!
        if (!talk.isSingleMode) {
            talk.cipheredNum -= 1
        }

        _ = updateOrCreateMessageInArray(talk, message: message)
        talkService.updateTalkInArray(talk, withMessages: true)
    }
    
    func markTalkAsReaded(_ talk: FriendTalk) {
        messageNetworkService.markTalkAsReaded(talk) { (error) -> Void in
            if let requestError = error {
                print(requestError)
            } else {
                //do nothing
            }
        }
    }
    
    fileprivate func getMessagesLastUpdate(_ talk: FriendTalk) -> Date {
        var lastUpdate: Date?
        
        for message in talk.messages {
            //ignore local messages
            if ((message as! RemoteMessage).isLocal) {
                continue
            }
            
            if (lastUpdate == nil || message.lastUpdate.isGreater(lastUpdate!)) {
                lastUpdate = message.lastUpdate as Date
            }
        }
        
        if (lastUpdate != nil) {
            return lastUpdate!
        } else {
            return Date.defaultPast()
        }
    }
    
    fileprivate func updateOrCreateMessageInArray(_ talk: FriendTalk, message: RemoteMessage) -> Bool {
        for i in 0..<talk.messages.count {
            let sameId = (message.id != "" && (message.id == (talk.messages[i] as! RemoteMessage).id))
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
