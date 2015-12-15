//
//  InAppNetworkService.swift
//  WTFChat
//
//  Created by Artem Chuzhmarov on 15/12/15.
//  Copyright © 2015 Artem Chuzhmarov. All rights reserved.
//

import Foundation

class InAppNetworkService: NSObject {
    
    func verifyInAppPurchase(receipt: NSData, productId: ProductIdentifier, completion:(error: NSError?) -> Void) {
        /*let postJSON = message.getNewJson()
        
        networkService.post(postJSON, relativeUrl: "messages/add") {json, error -> Void in
            if let requestError = error {
                completion(message: nil, error: requestError)
            } else {
                if let messageJson = json {
                    do {
                        let message = try Message.parseFromJson(messageJson)
                        completion(message: message, error: nil)
                    } catch let error as NSError {
                        completion(message: nil, error: error)
                    }
                } else {
                    completion(message: nil, error: nil)
                }
            }
        }*/
    }
    
}