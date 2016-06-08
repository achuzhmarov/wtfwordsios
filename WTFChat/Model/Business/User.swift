import Foundation

class User: NSObject {
    var login: String
    var hints: Int = 0
    var talks = [FriendTalk]()

    var lastUpdate: NSDate = NSDate.defaultPast()
    var exp: Int = 0
    var singleExp: Int = 0
    var newHints: Int = 0
    var friends = [FriendInfo]()

    var name: String = ""
    var pushNew: Bool = true
    var pushDeciphered: Bool = true

    var rating: Int = 0

    var buyNonConsum = [String]()

    var freeHintsGained: Int = 0

    init(login: String) {
        self.login = login
    }

    init(login: String, hints: Int) {
        self.login = login
        self.hints = hints
    }

    init(login: String, hints: Int, talks: [FriendTalk], lastUpdate: NSDate,
         exp: Int, singleExp: Int, newHints: Int, friends: [FriendInfo],
         name: String, pushNew: Bool, pushDeciphered: Bool, rating: Int,
         buyNonConsum: [String], freeHintsGained: Int)
    {
        self.login = login
        self.hints = hints
        self.talks = talks
        self.lastUpdate = lastUpdate
        self.exp = exp
        self.singleExp = singleExp
        self.newHints = newHints
        self.friends = friends

        self.name = name
        self.pushNew = pushNew
        self.pushDeciphered = pushDeciphered

        self.rating = rating

        self.buyNonConsum = buyNonConsum

        self.freeHintsGained = freeHintsGained
    }

    func updateInfo(user: User) {
        self.lastUpdate = user.lastUpdate
        self.hints = user.hints
        self.newHints = user.newHints
        self.exp = user.exp
        self.singleExp = user.singleExp

        self.name = user.name
        self.pushNew = user.pushNew
        self.pushDeciphered = user.pushDeciphered
        self.rating = user.rating

        self.freeHintsGained = user.freeHintsGained

        for friendLvl in user.friends {
            updateFriendLvlInArray(friendLvl)
        }

        for item in user.buyNonConsum {
            if !self.buyNonConsum.contains(item) {
                self.buyNonConsum.append(item)
            }
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

    func getFullExp() -> Int {
        return exp + singleExp
    }
}
