import Foundation

extension CurrentUserService {
    func earnSingleExp(_ earnedExp: Int) {
        user.singleExp += earnedExp
        saveUserInLocalStorage()
    }

    func clearUserNewSuggestions() {
        user.newHints = 0
        saveUserInLocalStorage()
    }

    func updateInfo(_ newUserInfo: User) {
        user.updateInfo(newUserInfo)
        saveUserInLocalStorage()
    }

    func addFriend(_ friend: FriendInfo) {
        user.friends.append(friend)
    }

    func updateName(_ name: String) {
        user.name = name
        saveUserInLocalStorage()
    }

    func updatePushNew(_ pushNew: Bool) {
        user.pushNew = pushNew
        saveUserInLocalStorage()
    }

    func updatePushDeciphered(_ pushDeciphered: Bool) {
        user.pushDeciphered = pushDeciphered
        saveUserInLocalStorage()
    }

    func useHints(_ hintsUsed: Int) {
        user.hints -= hintsUsed
        saveUserInLocalStorage()
    }

    func addFreeHint() {
        if canAddFreeAdHint() {
            user.hints += 1
            user.adHintsGained += 1
            saveUserInLocalStorage()
        }
    }

    func addHints(_ hints: Int) {
        user.hints += hints
        saveUserInLocalStorage()
    }

    func addHintsForLvlUp() -> Int {
        let hintsForLvl = expService.getHintsForLvl(getUserLvl())
        user.hints += hintsForLvl
        saveUserInLocalStorage()

        return hintsForLvl
    }

    func updateLastLogin(_ lastLogin: Date) {
        user.lastLogin = lastLogin
        saveUserInLocalStorage()
    }

    func clearAdHintsLimit() {
        user.adHintsGained = 0
        saveUserInLocalStorage()
    }
}
