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
    var rating: Int
    var talks = [Talk]()
    
    //TODO - delete if not needed
    var friends = [String]()
    
    init(login: String, suggestions: Int, rating: Int) {
        self.login = login
        self.suggestions = suggestions
        self.rating = rating
    }
    
    init(login: String, suggestions: Int, rating: Int, talks: [Talk], friends: [String]) {
        self.login = login
        self.suggestions = suggestions
        self.rating = rating
        self.talks = talks
        self.friends = friends
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
        var rating: Int
        var talks = [Talk]()
        var friends = [String]()
        
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
        
        if let value = json["rating"].int {
            rating = value
        } else {
            throw json["rating"].error!
        }

        if let value = json["friends"].array {
            for friendJson in value {
                if let friend = friendJson.string {
                    friends.append(friend)
                } else {
                    throw friendJson.error!
                }
            }
        } else {
            throw json["friends"].error!
        }

        if let value = json["talks"].array {
            for talkJson in value {
                try talks.append(Talk.parseFromJson(talkJson))
            }
        } else {
            throw json["talks"].error!
        }
        
        return User(
            login: login,
            suggestions: suggestions,
            rating: rating,
            talks: talks,
            friends: friends
        )
    }
}
