import Foundation

class MessageTableView: BaseMessageTableView {
    fileprivate let currentUserService: CurrentUserService = serviceLocator.get(CurrentUserService)

    override func isOutcomingMessageCell(_ index: Int, message: Message) -> Bool {
        return ((message as! RemoteMessage).author == currentUserService.getUserLogin())
    }
}
