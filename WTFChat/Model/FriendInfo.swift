//
//  FriendLvl.swift
//  WTFChat
//
//  Created by Artem Chuzhmarov on 28/10/15.
//  Copyright © 2015 Artem Chuzhmarov. All rights reserved.
//

import Foundation

class FriendInfo {
    var login: String
    var lvl: Int
    var name: String
    
    init(login: String, lvl: Int, name: String) {
        self.login = login
        self.lvl = lvl
        self.name = name
    }

    func getDisplayName() -> String {
        if (name != "") {
            return name.capitalizedString
        } else {
            return login.capitalizedString
        }
    }
    
    class func parseFromJson(json: JSON) throws -> FriendInfo {
        var login: String
        var lvl: Int
        var name: String
        
        if let value = json["login"].string {
            login = value
        } else {
            throw json["login"].error!
        }
        
        if let value = json["lvl"].int {
            lvl = value
        } else {
            throw json["lvl"].error!
        }
        
        if let value = json["name"].string {
            name = value
        } else {
            throw json["name"].error!
        }
        
        return FriendInfo(
            login: login,
            lvl: lvl,
            name: name
        )
    }
}