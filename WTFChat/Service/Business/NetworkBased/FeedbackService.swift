import Foundation
import SwiftyJSON

class FeedbackService: Service {
    private let feedbackNetworkService: FeedbackNetworkService
    private let currentUserService: CurrentUserService

    init(feedbackNetworkService: FeedbackNetworkService, currentUserService: CurrentUserService) {
        self.feedbackNetworkService = feedbackNetworkService
        self.currentUserService = currentUserService
    }

    func sendFeedback(fromEmail: String, text: String,
            completion:@escaping (_ success: Bool) -> Void) {

        let id = currentUserService.getUserLogin()

        feedbackNetworkService.sendFeedback(fromEmail: fromEmail, text: text, id: id) {
            (success, error) -> Void in
                completion(success)
        }
    }
}
