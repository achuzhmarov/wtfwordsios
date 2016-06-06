import Foundation

class SingleMessageCell: BaseMessageCell {
    private let avatarService: AvatarService = serviceLocator.get(AvatarService)

    override func updateMessage(message: Message, isOutcoming: Bool) {
        super.updateMessage(message, isOutcoming: isOutcoming)

        messageText.text = message.text()
        messageText.sizeToFit()

        friendImage?.image = avatarService.getSingleModeImage(UInt(friendImage.bounds.height))
    }
}
