//
// Created by Artem Chuzhmarov on 30/05/16.
// Copyright (c) 2016 Artem Chuzhmarov. All rights reserved.
//

import Foundation

class IosNetworkService: Service {
    private let networkService: NetworkService

    init(networkService: NetworkService) {
        self.networkService = networkService
    }

    func updateDeviceToken(deviceToken: NSString?) {
        var postJSON: JSON? = nil

        if deviceToken != nil {
            let userData = [
                    "device_token": deviceToken!
            ]

            postJSON = JSON(userData)
        }

        networkService.post(postJSON, relativeUrl: "user/ios_token") { (json, error) -> Void in
            if let requestError = error {
                print(requestError)
            } else {
                //ok - do nothing
            }
        }
    }
}
