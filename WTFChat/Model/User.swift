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
    var lvl: Int = 1
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
        var suggestions: Int
        var talks = [Talk]()
        var lastUpdate: NSDate
        var exp: Int
        var lvl: Int
        var newSuggestions: Int
        var friendsLvls = [FriendLvl]()
        
        if let value = json["login"].string {
            login = value
        } else {
            throw json["login"].error!
        }
        
        if let value = json["suggestions"].int {
            suggestions = value
        } else {
            throw json["suggestions"].error!
        }

        if let value = json["talks"].array {
            for talkJson in value {
                try talks.append(Talk.parseFromJson(talkJson))
            }
        } else {
            throw json["talks"].error!
        }
        
        if let value = json["last_update"].string {
            if let parsedTimestamp = NSDate.parseDateFromStringJSON(value) {
                lastUpdate = parsedTimestamp
            } else {
                lastUpdate = NSDate.defaultPast()
                //throw NSError(code: 1, message: "Could not parse lastUpdate")
            }
        } else {
            lastUpdate = NSDate.defaultPast()
            //throw json["last_update"].error!
        }
        
        if let value = json["exp"].int {
            exp = value
        } else {
            throw json["exp"].error!
        }
        
        if let value = json["lvl"].int {
            lvl = value
        } else {
            throw json["lvl"].error!
        }
        
        if let value = json["new_suggestions"].int {
            newSuggestions = value
        } else {
            throw json["new_suggestions"].error!
        }
        
        if let value = json["friends_lvls"].array {
            for friendJson in value {
                try friendsLvls.append(FriendLvl.parseFromJson(friendJson))
            }
        } else {
            throw json["friends_lvls"].error!
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
