import Foundation

class BaseMessageCell: UITableViewCell {
    private let timeService: TimeService = serviceLocator.get(TimeService)

    @IBOutlet weak var friendImage: UIImageView!
    @IBOutlet weak var messageText: RoundedLabel!
    @IBOutlet weak var timeText: UILabel!

    func initStyle() {
        friendImage?.layer.borderColor = UIColor.whiteColor().CGColor
        friendImage?.layer.cornerRadius = friendImage.bounds.width/2
        friendImage?.clipsToBounds = true

        self.selectionStyle = .None;

        messageText.textColor = Color.Font
        messageText.font = UIFont(name: messageText.font.fontName, size: 16)
        messageText.layer.cornerRadius = 10.0
        messageText.initStyle()
    }

    func updateMessage(message: Message, isOutcoming: Bool) {
        initStyle()

        timeText?.attributedText = timeService.parseTime(message.timestamp)

        messageText.tagObject = message

        switch message.getMessageStatus() {
            case .Success:
                messageText.layer.backgroundColor = Color.Success.CGColor
            case .Failed:
                messageText.layer.backgroundColor = Color.Failed.CGColor
            case .Ciphered:
                messageText.layer.backgroundColor = Color.Ciphered.CGColor
        }
    }
}
