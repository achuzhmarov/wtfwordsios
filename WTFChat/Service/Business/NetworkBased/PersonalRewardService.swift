import Foundation
import SwiftyJSON
import Localize_Swift

class PersonalRewardService: Service {
    private let personalRewardNetworkService: PersonalRewardNetworkService
    private let currentUserService: CurrentUserService

    private let GOT_WTF_TEXT = "You got"

    init(personalRewardNetworkService: PersonalRewardNetworkService, currentUserService: CurrentUserService) {
        self.personalRewardNetworkService = personalRewardNetworkService
        self.currentUserService = currentUserService
    }

    func checkPersonalReward() {
        let id = currentUserService.getUserLogin()

        personalRewardNetworkService.checkPersonalReward(id: id) {
            (personalReward, error) -> Void in
                if let responseError = error {
                    print(responseError)
                } else {
                    self.computePersonalReward(personalReward!)
                }
        }
    }

    private func computePersonalReward(_ personalReward: PersonalReward) {


        if (personalReward.hasReward) {
            currentUserService.addWtf(personalReward.wtfs)
            let title = GOT_WTF_TEXT.localized() + " " + String(personalReward.wtfs) + " WTF!"
            WTFOneButtonAlert.show(title, message: personalReward.message)
        } else {
            //do nothing
        }
    }
}
