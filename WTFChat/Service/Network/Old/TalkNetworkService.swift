//
// Created by Artem Chuzhmarov on 30/05/16.
// Copyright (c) 2016 Artem Chuzhmarov. All rights reserved.
//

import Foundation

class TalkNetworkService: Service {
    private let networkService: NetworkService

    init(networkService: NetworkService) {
        self.networkService = networkService
    }

    func getNewUnreadTalks(lastUpdate: NSDate, completion: (talks: [FriendTalk]?, error: NSError?) -> Void) {
        let lastUpdateData = [
                "last_update": NSDate.parseStringJSONFromDate(lastUpdate)!
        ]

        let postJSON = JSON(lastUpdateData)

        networkService.post(postJSON, relativeUrl: "user/new_talks_by_time") { (json, error) -> Void in
            if let requestError = error {
                completion(talks: nil, error: requestError)
            } else {
                if let talksJson = json {
                    do {
                        let talks = try JsonTalkParser.arrayFromJson(talksJson)
                        completion(talks: talks, error: nil)
                    } catch let error as NSError {
                        completion(talks: nil, error: error)
                    }
                } else {
                    completion(talks: nil, error: nil)
                }
            }
        }
    }
}
