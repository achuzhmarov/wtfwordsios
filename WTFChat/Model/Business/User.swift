import Foundation

class User: JsonUser {
    func updateInfo(user: User) {
        self.lastUpdate = user.lastUpdate
        self.suggestions = user.suggestions
        self.newSuggestions = user.newSuggestions
        self.exp = user.exp
        self.lvl = user.lvl

        self.email = user.email
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
