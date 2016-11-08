import UIKit

class MessageCell: BaseMessageCell {
    fileprivate let avatarService: AvatarService = serviceLocator.get(AvatarService.self)
    
    override func updateMessage(_ message: Message, isOutcoming: Bool) {
        super.updateMessage(message, isOutcoming: isOutcoming)

        if (isOutcoming) {
            messageText.text = message.clearText()
        } else {
            messageText.text = message.text()
        }

        messageText.sizeToFit()

        friendImage?.image = avatarService.getImage((message as! RemoteMessage).author,
                diameter: UInt(friendImage.bounds.height))
    }
}
