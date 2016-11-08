import Foundation
import SwiftyJSON

class InAppNetworkServiceOld: Service {
    fileprivate let networkService: NetworkService

    init(networkService: NetworkService) {
        self.networkService = networkService
    }
    
    func verifyInAppPurchase(_ receipt: String, productId: ProductIdentifier,
        completion:@escaping (_ userInfo: User?, _ error: NSError?) -> Void) {
            
        let userData: [String: NSString] = [
            "product_id": productId as NSString,
            "receipt": receipt as NSString
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
