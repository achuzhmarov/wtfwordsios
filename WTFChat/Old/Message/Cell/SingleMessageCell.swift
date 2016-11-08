import Foundation

class SingleMessageCell: BaseMessageCell {
    fileprivate let avatarService: AvatarService = serviceLocator.get(AvatarService)

    override func updateMessage(_ message: Message, isOutcoming: Bool) {
        super.updateMessage(message, isOutcoming: isOutcoming)

        messageText.text = message.text()
        messageText.sizeToFit()

        friendImage?.image = avatarService.getSingleModeImage(UInt(friendImage.bounds.height))
    }
}
