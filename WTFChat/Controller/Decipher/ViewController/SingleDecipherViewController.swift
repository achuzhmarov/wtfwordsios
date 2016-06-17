import Foundation

class SingleDecipherViewController: BaseDecipherViewController {
    private let singleModeService: SingleModeService = serviceLocator.get(SingleModeService)
    private let singleMessageService: SingleMessageService = serviceLocator.get(SingleMessageService)
    private let messageCipherService: MessageCipherService = serviceLocator.get(MessageCipherService)

    @IBOutlet weak var difficultySelector: UISegmentedControl!
    @IBOutlet weak var startTimerLabel: UILabel!
    @IBOutlet weak var exampleLabel: RoundedLabel!
    @IBOutlet weak var textPreviewLabel: RoundedLabel!

    private let cipherDifficulties = CipherDifficulty.getAll()
    private var selectedDifficulty = CipherDifficulty.Easy

    var level: Level!
    var messageText: String!

    override func viewDidLoad() {
        messageText = singleMessageService.getTextForLevel(level)
        updateMessage()
        super.viewDidLoad()
    }

    @IBAction func difficultyChanged(sender: AnyObject) {
        selectedDifficulty = cipherDifficulties[difficultySelector.selectedSegmentIndex]
        updateMessage()
    }

    @IBAction func startPressed(sender: AnyObject) {
        if (!isStarted) {
            start()
        }
    }

    override func sendMessageUpdate() {
        //singleMessageService.updateMessage(message as! SingleMessage)
    }

    override func sendMessageDecipher() {
        let singleMessage = message as! SingleMessage

        singleModeService.finishDecipher(singleMessage)

        if (message.exp > 0) {
            let starStatus = singleModeService.getStarStatus(singleMessage)
            self.expGainView.runProgress(message.exp, starStatus: starStatus)
        }
    }

    private func updateMessage() {
        message = singleMessageService.getMessageForLevel(level, difficulty: selectedDifficulty, text: messageText)
        updateTime()
        updateMessageExample()
        updateMessagePreview()
    }

    private func updateTime() {
        let timer = Timer(seconds: messageCipherService.getTimerSeconds(message))
        startTimerLabel.text = timer.getTimeString()
        //startTimerLabel.text = "Time: " + timer.getTimeString()
    }

    private func updateMessageExample() {
        exampleLabel.initStyle()

        exampleLabel.textColor = UIColor.whiteColor()
        //exampleLabel.font = UIFont(name: textPreviewLabel.font.fontName, size: 17)

        exampleLabel.layer.backgroundColor = Color.Ciphered.CGColor
        exampleLabel.layer.cornerRadius = 8.0
        exampleLabel.translatesAutoresizingMaskIntoConstraints = false

        let exampleMessage = messageCipherService.createExampleMessage(
            level.category.cipherType, cipherDifficulty: selectedDifficulty
        )

        exampleLabel.text = exampleMessage.ciphered()
    }

    private func updateMessagePreview() {
        textPreviewLabel.initStyle()

        textPreviewLabel.textColor = UIColor.whiteColor()
        textPreviewLabel.font = UIFont(name: textPreviewLabel.font.fontName, size: 17)

        textPreviewLabel.layer.backgroundColor = Color.Ciphered.CGColor
        textPreviewLabel.layer.cornerRadius = 8.0
        textPreviewLabel.translatesAutoresizingMaskIntoConstraints = false
        textPreviewLabel.numberOfLines = 0

        textPreviewLabel.text = message.text()
    }
}
