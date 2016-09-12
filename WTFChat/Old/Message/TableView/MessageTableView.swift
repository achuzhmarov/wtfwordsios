import Foundation

class MessageTableView: BaseMessageTableView {
    private let currentUserService: CurrentUserService = serviceLocator.get(CurrentUserService)

    override func isOutcomingMessageCell(index: Int, message: Message) -> Bool {
        return ((message as! RemoteMessage).author == currentUserService.getUserLogin())
    }
}