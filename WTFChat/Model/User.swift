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
    var friendsLvls = [FriendLvl]()
    
    init(login: String, suggestions: Int) {
        self.login = login
        self.suggestions = suggestions
    }
    
    init(login: String, suggestions: Int, talks: [Talk], lastUpdate: NSDate,
        exp: Int, lvl: Int, newSuggestions: Int, friendsLvls: [FriendLvl])
    {
        self.login = login
        self.suggestions = suggestions
        self.talks = talks
        self.lastUpdate = lastUpdate
        self.exp = exp
        self.lvl = lvl
        self.newSuggestions = newSuggestions
        self.friendsLvls = friendsLvls
    }
    
    func updateInfo(user: User) {
        self.lastUpdate = user.lastUpdate
        self.suggestions = user.suggestions
        self.newSuggestions = user.newSuggestions
        self.exp = user.exp
        self.lvl = user.lvl
        
        for friendLvl in user.friendsLvls {
            updateFriendLvlInArray(friendLvl)
        }
    }
    
    private func updateFriendLvlInArray(friendLvl: FriendLvl) {
        for i in 0..<friendsLvls.count {
            if (friendLvl.login == friendsLvls[i].login) {
                friendsLvls[i] = friendLvl
                return
            }
        }
        
        friendsLvls.append(friendLvl)
    }

    
    class func parseFriendsFromJson(json: JSON) throws -> [String] {
        var friends = [String]()
        
        if let value = json.array {
            for friendJson in value {
                if let friend = friendJson.string {
                    friends.append(friend)
                } else {
                    throw friendJson.error!
                }
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
        var friendsLvls = [FriendLvl]()
        
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
                try friendsLvls.append(FriendLvl.parseFromJson(friendJson))
            }
        } else if let error = json["friends_lvls"].error {
            throw error
        }
        
        return User(
            login: login,
            suggestions: suggestions,
            talks: talks,
            lastUpdate: lastUpdate,
            exp: exp,
            lvl: lvl,
            newSuggestions: newSuggestions,
            friendsLvls: friendsLvls
        )
    }
}
