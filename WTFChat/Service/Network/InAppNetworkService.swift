//
//  InAppNetworkService.swift
//  WTFChat
//
//  Created by Artem Chuzhmarov on 15/12/15.
//  Copyright © 2015 Artem Chuzhmarov. All rights reserved.
//

import Foundation

class InAppNetworkService: Service {
    private let networkService: NetworkService

    init(networkService: NetworkService) {
        self.networkService = networkService
    }
    
    func verifyInAppPurchase(receipt: String, productId: ProductIdentifier,
        completion:(userInfo: User?, error: NSError?) -> Void) {
            
        let userData: [String: NSString] = [
            "product_id": productId,
            "receipt": receipt
        ]
        
        let postJSON = JSON(userData)
        
        networkService.post(postJSON, relativeUrl: "apple/buy") {json, error -> Void in
            if let requestError = error {
                completion(userInfo: nil, error: requestError)
            } else {
                if let userJson = json {
                    do {
                        let user = try JsonUserParser.fromJson(userJson)
                        completion(userInfo: user, error: nil)
                    } catch let error as NSError {
                        completion(userInfo: nil, error: error)
                    }
                }
            }
        }
    }
    
}