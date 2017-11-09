import Foundation
import SwiftyJSON

class PersonalRewardNetworkService: Service {
    private let networkService: NetworkService

    init(networkService: NetworkService) {
        self.networkService = networkService
    }

    func checkPersonalReward(id: String,
            completion:@escaping (_ personalReward: Reward?, _ error: NSError?) -> Void) {

        let request: [String: NSString] = [
            "id": id as NSString,
        ]

        let postJSON = JSON(request)

        networkService.post(postJSON, relativeUrl: "personal_reward") {json, error -> Void in
            if let requestError = error {
                completion(nil, requestError)
            } else {
                do {
                    let personalReward = try JsonRewardParser.fromJson(json!)
                    completion(personalReward, nil)
                } catch let error as NSError {
                    completion(nil, error)
                }
            }
        }
    }
}
