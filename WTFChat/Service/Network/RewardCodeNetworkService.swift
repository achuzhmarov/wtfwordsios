import Foundation
import SwiftyJSON

class RewardCodeNetworkService: Service {
    private let networkService: NetworkService

    init(networkService: NetworkService) {
        self.networkService = networkService
    }

    func getRewardByCode(id: String, code: String,
            completion:@escaping (_ reward: Reward?, _ error: NSError?) -> Void) {

        let request: [String: NSString] = [
            "id": id as NSString,
            "code": code as NSString
        ]

        let postJSON = JSON(request)

        networkService.post(postJSON, relativeUrl: "reward_code") {json, error -> Void in
            if let requestError = error {
                completion(nil, requestError)
            } else {
                do {
                    let reward = try JsonRewardParser.fromJson(json!)
                    completion(reward, nil)
                } catch let error as NSError {
                    completion(nil, error)
                }
            }
        }
    }
}
