import Foundation
import SwiftyJSON

class InAppNetworkService: Service {
    fileprivate let networkService: NetworkService

    init(networkService: NetworkService) {
        self.networkService = networkService
    }

    func verifyInAppPurchase(_ receipt: String, productId: ProductIdentifier,
                             completion:@escaping (_ valid: Bool?, _ error: NSError?) -> Void) {

        let request: [String: NSString] = [
                "receipt": receipt as NSString
        ]

        let postJSON = JSON(request)

        networkService.post(postJSON, relativeUrl: "ios_inapp") {json, error -> Void in
            if let requestError = error {
                completion(false, requestError)
            } else {
                if let responseJson = json {
                    do {
                        if let valid = responseJson["valid"].bool {
                            completion(valid, nil)
                        } else {
                            throw responseJson["valid"].error!
                        }
                    } catch let error as NSError {
                        completion(false, error)
                    }
                }
            }
        }
    }

}
