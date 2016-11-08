import Foundation

class FriendInfo: NSObject {
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

    func getDisplayName() -> String {
        if (name != "") {
            return name.capitalized
        } else {
            return login.capitalized
        }
    }

    class func compareByLvl(_ user1: FriendInfo, user2: FriendInfo) -> Bool {
        if (user1.lvl > user2.lvl) {
            return true
        } else if (user1.lvl < user2.lvl) {
            return false
        } else {
            return user1.login.isGreater(user2.login)
        }
    }

    class func compareByExp(_ user1: FriendInfo, user2: FriendInfo) -> Bool {
        if (user1.exp > user2.exp) {
            return true
        } else if (user1.exp < user2.exp) {
            return false
        } else {
            return user1.login.isGreater(user2.login)
        }
    }
}
