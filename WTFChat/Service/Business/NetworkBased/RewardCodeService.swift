import Foundation
import SwiftyJSON
import Localize_Swift

class RewardCodeService: Service {
    private let rewardCodeNetworkService: RewardCodeNetworkService
    private let currentUserService: CurrentUserService

    private let GOT_WTF_TEXT = "You got"
    private let REWARD_CODE_EXPIRED_TEXT = "Sorry, this code is expired"
    private let REWARD_CODE_CLAIMED_TEXT = "You have already claimed this code"
    private let REWARD_CODE_INVALID_TEXT = "Sorry, this code is invalid"

    private let UNKNOWN_ERROR_TEXT = "Unknown error occured."

    init(rewardCodeNetworkService: RewardCodeNetworkService, currentUserService: CurrentUserService) {
        self.rewardCodeNetworkService = rewardCodeNetworkService
        self.currentUserService = currentUserService
    }

    func getRewardForCode(code: String, completion: ((Bool) -> ())? = nil) {
        let id = currentUserService.getUserLogin()

        rewardCodeNetworkService.getRewardByCode(id: id, code: code) {
            (reward, error) -> Void in
                if let responseError = error {
                    print(responseError)
                    WTFOneButtonAlert.show(self.UNKNOWN_ERROR_TEXT.localized(), message: nil) {
                        completion?(false)
                    }
                } else {
                    self.computeReward(reward!, completion: completion)
                }
        }
    }

    private func computeReward(_ reward: Reward, completion: ((Bool) -> ())?) {
        if (reward.hasReward) {
            currentUserService.addWtf(reward.wtfs)
            let title = GOT_WTF_TEXT.localized() + " " + String(reward.wtfs) + " WTF!"
            WTFOneButtonAlert.show(title, message: reward.message) {
                completion?(true)
            }
        } else if (reward.isExpired) {
            WTFOneButtonAlert.show(REWARD_CODE_EXPIRED_TEXT.localized()) {
                completion?(false)
            }
        } else if (reward.isAlreadyClaimed) {
            WTFOneButtonAlert.show(REWARD_CODE_CLAIMED_TEXT.localized()) {
                completion?(false)
            }
        } else {
            WTFOneButtonAlert.show(REWARD_CODE_INVALID_TEXT.localized()) {
                completion?(false)
            }
        }
    }
}
