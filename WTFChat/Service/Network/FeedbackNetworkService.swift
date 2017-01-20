import Foundation
import SwiftyJSON

class FeedbackNetworkService: Service {
    private let networkService: NetworkService

    init(networkService: NetworkService) {
        self.networkService = networkService
    }

    func sendFeedback(fromEmail: String, text: String, id: String,
            completion:@escaping (_ success: Bool, _ error: NSError?) -> Void) {

        let request: [String: NSString] = [
            "id": id as NSString,
            "fromEmail": fromEmail as NSString,
            "text": text as NSString
        ]

        let postJSON = JSON(request)

        networkService.post(postJSON, relativeUrl: "feedback") {json, error -> Void in
            if let requestError = error {
                completion(false, requestError)
            } else {
                do {
                    if let success = json!["success"].bool {
                        completion(success, nil)
                    } else {
                        throw json!["success"].error!
                    }
                } catch let error as NSError {
                    completion(false, error)
                }
            }
        }
    }
}
