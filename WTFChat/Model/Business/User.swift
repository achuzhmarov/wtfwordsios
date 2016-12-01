import Foundation

class User: NSObject {
    var login: String
    var hints: Int = 0 // TODO - deprecated
    var talks = [FriendTalk]()

    var lastUpdate: Date = Date.defaultPast()
    var lastLogin: Date = Date()
    var exp: Int = 0
    var singleExp: Int = 0
    var friends = [FriendInfo]()

    var name: String = ""
    var pushNew: Bool = true
    var pushDeciphered: Bool = true

    var rating: Int = 0

    var adWtfGained: Int = 0

    var wtf: Int = 30

    init(login: String) {
        self.login = login
    }

    init(login: String, wtf: Int) {
        self.login = login
        self.wtf = wtf
    }

    init(login: String, wtf: Int, talks: [FriendTalk], lastUpdate: Date,
         exp: Int, singleExp: Int, friends: [FriendInfo],
         name: String, pushNew: Bool, pushDeciphered: Bool, rating: Int, adWtfGained: Int)
    {
        self.login = login
        self.wtf = wtf
        self.talks = talks
        self.lastUpdate = lastUpdate
        self.exp = exp
        self.singleExp = singleExp
        self.friends = friends

        self.name = name
        self.pushNew = pushNew
        self.pushDeciphered = pushDeciphered

        self.rating = rating

        self.adWtfGained = adWtfGained
    }

    func updateInfo(_ user: User) {
        self.lastUpdate = user.lastUpdate
        self.hints = user.hints
        self.exp = user.exp
        self.singleExp = user.singleExp

        self.name = user.name
        self.pushNew = user.pushNew
        self.pushDeciphered = user.pushDeciphered
        self.rating = user.rating

        self.adWtfGained = user.adWtfGained

        for friendLvl in user.friends {
            updateFriendLvlInArray(friendLvl)
        }
    }

    fileprivate func updateFriendLvlInArray(_ friend: FriendInfo) {
        for i in 0..<friends.count {
            if (friend.login == friends[i].login) {
                friends[i] = friend
                return
            }
        }

        friends.append(friend)
    }

    func getFullExp() -> Int {
        return exp + singleExp
    }
}
