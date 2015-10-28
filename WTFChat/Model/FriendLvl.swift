//
//  FriendLvl.swift
//  WTFChat
//
//  Created by Artem Chuzhmarov on 28/10/15.
//  Copyright © 2015 Artem Chuzhmarov. All rights reserved.
//

import Foundation

class FriendLvl {
    var login: String
    var lvl: Int
    
    init(login: String, lvl: Int) {
        self.login = login
        self.lvl = lvl
    }
    
    class func parseFromJson(json: JSON) throws -> FriendLvl {
        var login: String
        var lvl: Int
        
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
        
        return FriendLvl(
            login: login,
            lvl: lvl
        )
    }
}