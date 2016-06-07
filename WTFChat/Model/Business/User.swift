import Foundation

class User: NSObject {
    var login: String
    var suggestions: Int
    var talks = [Talk]()

    var lastUpdate: NSDate = NSDate.defaultPast()
    var exp: Int = 0
    var lvl: Int = 0
    var newSuggestions: Int = 0
    var friends = [FriendInfo]()

    var name: String = ""
    var pushNew: Bool = true
    var pushDeciphered: Bool = true

    var rating: Int = 0

    var buyNonConsum = [String]()

    var freeHintsGained: Int = 0

    init(login: String, suggestions: Int) {
        self.login = login
        self.suggestions = suggestions
    }

    init(login: String, suggestions: Int, talks: [Talk], lastUpdate: NSDate,
         exp: Int, lvl: Int, newSuggestions: Int, friends: [FriendInfo],
         name: String, pushNew: Bool, pushDeciphered: Bool, rating: Int,
         buyNonConsum: [String], freeHintsGained: Int)
    {
        self.login = login
        self.suggestions = suggestions
        self.talks = talks
        self.lastUpdate = lastUpdate
        self.exp = exp
        self.lvl = lvl
        self.newSuggestions = newSuggestions
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
        self.suggestions = user.suggestions
        self.newSuggestions = user.newSuggestions
        self.exp = user.exp
        self.lvl = user.lvl

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
}
