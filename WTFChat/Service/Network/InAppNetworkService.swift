import Foundation

class InAppNetworkService: Service {
    private let networkService: NetworkService

    init(networkService: NetworkService) {
        self.networkService = networkService
    }

    func verifyInAppPurchase(receipt: String, productId: ProductIdentifier,
                             completion:(valid: Bool?, error: NSError?) -> Void) {

        let request: [String: NSString] = [
                "receipt": receipt
        ]

        let postJSON = JSON(request)

        networkService.post(postJSON, relativeUrl: "/ios_inapp") {json, error -> Void in
            if let requestError = error {
                completion(valid: false, error: requestError)
            } else {
                if let responseJson = json {
                    do {
                        if let valid = responseJson["valid"].bool {
                            completion(valid: valid, error: nil)
                        } else {
                            throw responseJson["valid"].error!
                        }
                    } catch let error as NSError {
                        completion(valid: false, error: error)
                    }
                }
            }
        }
    }

}
