import Foundation
import SwiftyJSON

class TalkNetworkService: Service {
    fileprivate let networkService: NetworkService

    init(networkService: NetworkService) {
        self.networkService = networkService
    }

    func getNewUnreadTalks(_ lastUpdate: Date, completion: @escaping (_ talks: [FriendTalk]?, _ error: NSError?) -> Void) {
        let lastUpdateData = [
                "last_update": Date.parseStringJSONFromDate(lastUpdate)!
        ]

        let postJSON = JSON(lastUpdateData)

        networkService.post(postJSON, relativeUrl: "user/new_talks_by_time") { (json, error) -> Void in
            if let requestError = error {
                completion(nil, requestError)
            } else {
                if let talksJson = json {
                    do {
                        let talks = try JsonTalkParser.arrayFromJson(talksJson)
                        completion(talks, nil)
                    } catch let error as NSError {
                        completion(nil, error)
                    }
                } else {
                    completion(nil, nil)
                }
            }
        }
    }
}
