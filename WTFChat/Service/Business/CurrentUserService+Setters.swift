import Foundation

extension CurrentUserService {
    func earnSingleExp(earnedExp: Int) {
        user.singleExp += earnedExp
        saveUserInLocalStorage()
    }

    func clearUserNewSuggestions() {
        user.newHints = 0
        saveUserInLocalStorage()
    }

    func updateInfo(newUserInfo: User) {
        user.updateInfo(newUserInfo)
        saveUserInLocalStorage()
    }

    func addFriend(friend: FriendInfo) {
        user.friends.append(friend)
    }

    func updateName(name: String) {
        user.name = name
        saveUserInLocalStorage()
    }

    func updatePushNew(pushNew: Bool) {
        user.pushNew = pushNew
        saveUserInLocalStorage()
    }

    func updatePushDeciphered(pushDeciphered: Bool) {
        user.pushDeciphered = pushDeciphered
        saveUserInLocalStorage()
    }

    func useHints(hintsUsed: Int) {
        user.hints -= hintsUsed
        saveUserInLocalStorage()
    }

    func addFreeHint() {
        if canAddFreeAdHint() {
            user.hints += 1
            user.freeHintsGained += 1
            saveUserInLocalStorage()
        }
    }

    func addHints(hints: Int) {
        user.hints += hints
        saveUserInLocalStorage()
    }

    func updateLastLogin(lastLogin: NSDate) {
        user.lastLogin = lastLogin
        saveUserInLocalStorage()
    }
}
