//
//  MessageDao.swift
//  wttc
//
//  Created by Artem Chuzhmarov on 05/09/15.
//  Copyright (c) 2015 Artem Chuzhmarov. All rights reserved.
//

import Foundation

class MessageNetworkService: NSObject {
    func markTalkAsReaded(talk: Talk, completion:(error: NSError?) -> Void) {
        networkService.post(nil, relativeUrl: "messages/read/\(talk.id)") { (json, error) -> Void in
            completion(error: error)
        }
    }
    
    func getMessagesByTalk(talk: Talk, completion:(messages: [Message]?, error: NSError?) -> Void) {
        networkService.get("messages/\(talk.id)") { (json, error) -> Void in
            if let requestError = error {
                completion(messages: nil, error: requestError)
            } else {
                do {
                    let messages = try Message.parseArrayFromJson(json!)
                    completion(messages: messages, error: nil)
                } catch let error as NSError {
                    completion(messages: nil, error: error)
                }
                
            }
        }
    }
    
    func getUnreadMessagesByTalk(
        talk: Talk,
        lastUpdate: NSDate,
        completion:(messages: [Message]?, error: NSError?) -> Void)
    {
        let lastUpdateData = [
            "last_update": NSDate.parseStringJSONFromDate(lastUpdate)!
        ]
        
        let postJSON = JSON(lastUpdateData)
        
        networkService.post(postJSON, relativeUrl: "messages/new/\(talk.id)") { (json, error) -> Void in
            if let requestError = error {
                completion(messages: nil, error: requestError)
            } else {
                if let messagesJson = json {
                    do {
                        let messages = try Message.parseArrayFromJson(messagesJson)
                        completion(messages: messages, error: nil)
                    } catch let error as NSError {
                        completion(messages: nil, error: error)
                    }
                } else {
                    completion(messages: nil, error: nil)
                }
            }
        }
    }
    
    func getEarlierMessagesByTalk(
        talk: Talk,
        skip: Int,
        completion:(messages: [Message]?, error: NSError?) -> Void)
    {
        networkService.get("messages/earlier/\(talk.id)/\(String(skip))") { (json, error) -> Void in
            if let requestError = error {
                completion(messages: nil, error: requestError)
            } else {
                if let messagesJson = json {
                    do {
                        let messages = try Message.parseArrayFromJson(messagesJson)
                        completion(messages: messages, error: nil)
                    } catch let error as NSError {
                        completion(messages: nil, error: error)
                    }
                } else {
                    completion(messages: nil, error: nil)
                }
            }
        }
    }
    
    func saveMessage(message: Message, completion:(message: Message?, error: NSError?) -> Void) {
        let postJSON = message.getNewJson()
        
        networkService.post(postJSON, relativeUrl: "messages/add") {json, error -> Void in
            if let requestError = error {
                completion(message: nil, error: requestError)
            } else {
                if let messageJson = json {
                    do {
                        let message = try Message.parseFromJson(messageJson)
                        completion(message: message, error: nil)
                    } catch let error as NSError {
                        completion(message: nil, error: error)
                    }
                } else {
                    completion(message: nil, error: nil)
                }
            }
        }
    }
    
    func decipherMessage(message: Message, completion:(message: Message?, error: NSError?) -> Void) {
        let postJSON = message.getDecipherJson()
        
        networkService.post(postJSON, relativeUrl: "messages/decipher") {json, error -> Void in
            if let requestError = error {
                completion(message: nil, error: requestError)
            } else {
                if let messageJson = json {
                    do {
                        let message = try Message.parseFromJson(messageJson)
                        completion(message: message, error: nil)
                    } catch let error as NSError {
                        completion(message: nil, error: error)
                    }
                } else {
                    completion(message: nil, error: nil)
                }
            }
        }
    }
}