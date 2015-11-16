//
//  User.swift
//  wttc
//
//  Created by Artem Chuzhmarov on 05/09/15.
//  Copyright (c) 2015 Artem Chuzhmarov. All rights reserved.
//

import Foundation

class User {
    var login: String
    var suggestions: Int
    var talks = [Talk]()
    
    var lastUpdate: NSDate = NSDate.defaultPast()
    var exp: Int = 0
    var lvl: Int = 0
    var newSuggestions: Int = 0
    var friends = [FriendInfo]()
    
    var email: String = ""
    var name: String = ""
    var pushNew: Bool = true
    var pushDeciphered: Bool = true
    
    init(login: String, suggestions: Int) {
        self.login = login
        self.suggestions = suggestions
    }
    
    init(login: String, suggestions: Int, talks: [Talk], lastUpdate: NSDate,
        exp: Int, lvl: Int, newSuggestions: Int, friends: [FriendInfo],
        email: String, name: String, pushNew: Bool, pushDeciphered: Bool)
    {
        self.login = login
        self.suggestions = suggestions
        self.talks = talks
        self.lastUpdate = lastUpdate
        self.exp = exp
        self.lvl = lvl
        self.newSuggestions = newSuggestions
        self.friends = friends
        
        self.email = email
        self.name = name
        self.pushNew = pushNew
        self.pushDeciphered = pushDeciphered
    }
    
    func updateInfo(user: User) {
        self.lastUpdate = user.lastUpdate
        self.suggestions = user.suggestions
        self.newSuggestions = user.newSuggestions
        self.exp = user.exp
        self.lvl = user.lvl
        
        self.email = user.email
        self.name = user.name
        self.pushNew = user.pushNew
        self.pushDeciphered = user.pushDeciphered
        
        for friendLvl in user.friends {
            updateFriendLvlInArray(friendLvl)
        }
    }
    
    private func updateFriendLvlInArray(friend: FriendInfo) {
        for i in 0..<friends.count {
            if (friend.login == friends[i].login) {
                friends[i] = friend
                return
            }
        }
        
        friends.append(friend)
    }

    class func parseFriendsFromJson(json: JSON) throws -> [FriendInfo] {
        var friends = [FriendInfo]()
        
        if let value = json.array {
            for friendJson in value {
                try friends.append(FriendInfo.parseFromJson(friendJson))
            }
        } else {
            throw json.error!
        }
        
        return friends
    }
    
    class func parseFromJson(json: JSON) throws -> User {
        var login: String
        var suggestions: Int = 0
        var talks = [Talk]()
        var lastUpdate: NSDate = NSDate.defaultPast()
        var exp: Int = 0
        var lvl: Int = 0
        var newSuggestions: Int = 0
        var friends = [FriendInfo]()
        
        var email: String
        var name: String
        var pushNew: Bool = true
        var pushDeciphered: Bool = true
        
        if let value = json["login"].string {
            login = value
        } else {
            throw json["login"].error!
        }
        
        if let value = json["suggestions"].int {
            suggestions = value
        } else if let error = json["suggestions"].error {
            throw error
        }

        if let value = json["talks"].array {
            for talkJson in value {
                try talks.append(Talk.parseFromJson(talkJson))
            }
        } else if (json["talks"].isEmpty) {
            //do nothing
        } else if let error = json["talks"].error {
            throw error
        }
        
        if let value = json["last_update"].string {
            if let parsedTimestamp = NSDate.parseDateFromStringJSON(value) {
                lastUpdate = parsedTimestamp
            } else {
                //throw NSError(code: 1, message: "Could not parse lastUpdate")
            }
        } else {
            //throw error
        }
        
        if let value = json["exp"].int {
            exp = value
        } else if let error = json["exp"].error {
            throw error
        }
        
        if let value = json["lvl"].int {
            lvl = value
        } else if let error = json["lvl"].error {
            throw error
        }
        
        if let value = json["new_suggestions"].int {
            newSuggestions = value
        } else if let error = json["new_suggestions"].error {
            throw error
        }
        
        if let value = json["friends_lvls"].array {
            for friendJson in value {
                try friends.append(FriendInfo.parseFromJson(friendJson))
            }
        } else if let error = json["friends_lvls"].error {
            throw error
        }
        
        if let value = json["email"].string {
            email = value
        } else {
            throw json["email"].error!
        }
        
        if let value = json["name"].string {
            name = value
        } else {
            throw json["name"].error!
        }
        
        if let value = json["push_new"].bool {
            pushNew = value
        } else {
            //do nothing
            //throw json["has_unread"].error!
        }
        
        if let value = json["push_deciphered"].bool {
            pushDeciphered = value
        } else {
            //do nothing
            //throw json["has_unread"].error!
        }
        
        return User(
            login: login,
            suggestions: suggestions,
            talks: talks,
            lastUpdate: lastUpdate,
            exp: exp,
            lvl: lvl,
            newSuggestions: newSuggestions,
            friends: friends,
            email: email,
            name: name,
            pushNew: pushNew,
            pushDeciphered: pushDeciphered
        )
    }
}
