import Foundation

class FriendInfo: JsonFriendInfo {
    func getDisplayName() -> String {
        if (name != "") {
            return name.capitalizedString
        } else {
            return login.capitalizedString
        }
    }

    class func compareByLvl(user1: FriendInfo, user2: FriendInfo) -> Bool {
        if (user1.lvl > user2.lvl) {
            return true
        } else if (user1.lvl < user2.lvl) {
            return false
        } else {
            return user1.login.isGreater(user2.login)
        }
    }

    class func compareByExp(user1: FriendInfo, user2: FriendInfo) -> Bool {
        if (user1.exp > user2.exp) {
            return true
        } else if (user1.exp < user2.exp) {
            return false
        } else {
            return user1.login.isGreater(user2.login)
        }
    }
}
