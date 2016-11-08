import Foundation

class BaseMessageCell: UITableViewCell {
    fileprivate let timeService: TimeService = serviceLocator.get(TimeService)

    @IBOutlet weak var friendImage: UIImageView!
    @IBOutlet weak var messageText: RoundedLabel!
    @IBOutlet weak var timeText: UILabel!

    fileprivate func initStyle() {
        friendImage?.layer.borderColor = UIColor.white.cgColor
        friendImage?.layer.cornerRadius = friendImage.bounds.width/2
        friendImage?.clipsToBounds = true

        self.selectionStyle = .none;

        messageText.textColor = Color.Text
        messageText.font = UIFont.init(name: messageText.font.fontName, size: 16)
        messageText.layer.cornerRadius = 10.0
    }

    func updateMessage(_ message: Message, isOutcoming: Bool) {
        initStyle()

        timeText?.attributedText = timeService.parseTime(message.timestamp)

        messageText.tagObject = message

        switch message.getMessageStatus() {
            case .success:
                messageText.addGradientToLabel(Gradient.Success)
                //messageText.layer.backgroundColor = Color.Success.CGColor
            case .failed:
                messageText.addGradientToLabel(Gradient.Failed)
                //messageText.layer.backgroundColor = Color.Failed.CGColor
            case .ciphered:
                messageText.addGradientToLabel(Gradient.Ciphered)
                //messageText.layer.backgroundColor = Color.Ciphered.CGColor
        }
    }
}
