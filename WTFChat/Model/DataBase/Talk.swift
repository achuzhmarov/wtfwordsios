//
//  Talk.swift
//  wttc
//
//  Created by Artem Chuzhmarov on 05/09/15.
//  Copyright (c) 2015 Artem Chuzhmarov. All rights reserved.
//

import Foundation

enum DecipherStatus: Int {
    case No = 1, Success, Failed
}

class Talk : BaseEntity {
    var users = [String]()
    var hasUnread: Bool
    var decipherStatus: DecipherStatus
    var cipheredNum: Int
    var lastUpdate: NSDate
    var messageCount: Int
    
    var messages = [Message]()
    
    var lastMessage: Message?
    var isSingleMode = false
    
    override init(id: String) {
        self.hasUnread = false
        self.cipheredNum = 0
        self.decipherStatus = DecipherStatus.No
        self.lastUpdate = NSDate()
        self.messageCount = 0
        
        super.init(id: id)
    }
    
    init(id: String, hasUnread: Bool, cipheredNum: Int) {
        self.hasUnread = hasUnread
        self.cipheredNum = cipheredNum
        self.decipherStatus = DecipherStatus.No
        self.lastUpdate = NSDate()
        self.messageCount = 0
        
        super.init(id: id)
    }
    
    init(id: String, hasUnread: Bool, cipheredNum: Int, lastMessage: Message?, users: [String], decipherStatus: DecipherStatus, lastUpdate: NSDate, messageCount: Int) {
        
        self.hasUnread = hasUnread
        self.cipheredNum = cipheredNum
        self.lastMessage = lastMessage
        self.users = users
        self.decipherStatus = decipherStatus
        self.lastUpdate = lastUpdate
        self.messageCount = messageCount
        
        super.init(id: id)
    }
    
    func appendMessage(message: Message) {
        messages.append(message)
        lastMessage = message
    }
    
    class func parseArrayFromJson(json: JSON) throws -> [Talk] {
        var talks = [Talk]()
        
        if let value = json.array {
            for talkJson in value {
                try talks.append(Talk.parseFromJson(talkJson))
            }
        } else {
            throw json.error!
        }
        
        return talks
    }
    
    class func parseFromJson(json: JSON) throws -> Talk {
        var id: String
        var hasUnread: Bool
        var cipheredNum: Int
        var lastMessage: Message?
        var users = [String]()
        var decipherStatus: DecipherStatus
        var lastUpdate: NSDate
        var messageCount: Int
        
        if let value = json["id"].string {
            id = value
        } else {
            throw json["id"].error!
        }
        
        if let value = json["users"].array {
            for userJson in value {
                if let user = userJson.string {
                    users.append(user)
                } else {
                    throw userJson.error!
                }
            }
        } else {
            throw json["users"].error!
        }
        
        if let value = json["has_unread"].bool {
            hasUnread = value
        } else {
            throw json["has_unread"].error!
        }
        
        if let value = json["has_deciphered"].int {
            if (value == 0) {
                decipherStatus = DecipherStatus.No
            } else {
                decipherStatus = DecipherStatus(rawValue: value)!
            }
        } else {
            decipherStatus = DecipherStatus.No
            //throw json["has_deciphered"].error!
        }
        
        if let value = json["ciphered_num"].int {
            cipheredNum = value
        } else {
            throw json["ciphered_num"].error!
        }
        
        if let value = json["message_count"].int {
            messageCount = value
        } else {
            throw json["message_count"].error!
        }
        
        if json["last_message"].null == nil {
            lastMessage = try Message.parseFromJson(json["last_message"])
        }
        
        if let value = json["last_update"].string {
            if let parsedTimestamp = NSDate.parseDateFromStringJSON(value) {
                lastUpdate = parsedTimestamp
            } else {
                lastUpdate = NSDate()
                //throw NSError(code: 1, message: "Could not parse lastUpdate")
            }
        } else {
            lastUpdate = NSDate()
            //throw json["last_update"].error!
        }
        
        return Talk(
            id: id,
            hasUnread: hasUnread,
            cipheredNum: cipheredNum,
            lastMessage: lastMessage,
            users: users,
            decipherStatus: decipherStatus,
            lastUpdate: lastUpdate,
            messageCount: messageCount
        )
    }
}