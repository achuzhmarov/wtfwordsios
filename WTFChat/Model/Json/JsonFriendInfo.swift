import Foundation

class JsonFriendInfo : NSObject {
    var login: String
    var lvl: Int
    var exp: Int
    var name: String
    var rating: Int
    
    init(login: String, lvl: Int, name: String, exp: Int, rating: Int) {
        self.login = login
        self.lvl = lvl
        self.name = name
        self.exp = exp
        self.rating = rating
    }
    
    class func parseFromJson(json: JSON) throws -> FriendInfo {
        var login: String
        var lvl: Int
        var name: String
        var exp: Int = 0
        var rating: Int = 0
        
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
        
        if let value = json["exp"].int {
            exp = value
        } else {
            //do nothing
            //throw json["exp"].error!
        }
        
        if let value = json["rating"].int {
            rating = value
        } else {
            //do nothing
            //throw json["rating"].error!
        }
        
        return FriendInfo(
            login: login,
            lvl: lvl,
            name: name,
            exp: exp,
            rating: rating
        )
    }
}