import Foundation
import Localize_Swift

class DailyHintsService: Service {
    let inAppService: InAppService
    let currentUserService: CurrentUserService

    private let DAILY_HINTS_TEXT = "Daily free hints!\nToday you got".localized()

    init(inAppService: InAppService, currentUserService: CurrentUserService) {
        self.inAppService = inAppService
        self.currentUserService = currentUserService
    }

    func computeDailyHints() {
        let now = NSDate()
        let lastLogin = currentUserService.getLastLogin()

        if (checkDailyHints(now, lastLogin: lastLogin)) {
            addDailyHints()
            currentUserService.clearAdHintsLimit()
        }

        currentUserService.updateLastLogin(now)
    }

    private func checkDailyHints(now: NSDate, lastLogin: NSDate) -> Bool {
        if (lastLogin.getYear() < now.getYear()
                || lastLogin.getMonth() < now.getMonth()
                || lastLogin.getDay() < now.getDay()) {

            return true
        }

        return false
    }

    private func addDailyHints() {
        let userLvl = currentUserService.getUserLvl()
        let hints = getRandomDailyHints(userLvl)

        currentUserService.addHints(hints)

        WTFOneButtonAlert.show(DAILY_HINTS_TEXT + " " + hints, message: nil)
    }

    func getRandomDailyHints(userLvl: Int) -> Int {
        var twoBorder: Int
        var threeBorder: Int

        //calculate probability border - max 100
        twoBorder = 70 - userLvl / 2
        threeBorder = 100 - userLvl / 4

        let randomNumber = Int(arc4random_uniform(UInt32(100)))
        var hints: Int

        if randomNumber < twoBorder {
            hints = 1
        } else if randomNumber < threeBorder {
            hints = 2
        } else {
            hints = 3
        }

        if inAppService.isPurchased(IAPProducts.HINTS_X2) {
            hints = hints * 2
        }

        return hints
    }
}
