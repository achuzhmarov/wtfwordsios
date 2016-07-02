import Foundation

class SingleDecipherViewController: BaseDecipherViewController {
    private let singleModeService: SingleModeService = serviceLocator.get(SingleModeService)
    private let singleMessageService: SingleMessageService = serviceLocator.get(SingleMessageService)
    private let messageCipherService: MessageCipherService = serviceLocator.get(MessageCipherService)
    private let currentUserService: CurrentUserService = serviceLocator.get(CurrentUserService)

    @IBOutlet weak var difficultySelector: UISegmentedControl!
    @IBOutlet weak var startTimerLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var textPreviewLabel: UILabel!

    private let cipherDifficulties = CipherDifficulty.getAll()
    private var selectedDifficulty = CipherDifficulty.Normal

    var level: Level!
    var messageText: String!
    var messageCategory: TextCategory!

    override func viewDidLoad() {
        selectedDifficulty = currentUserService.getLastSelectedDifficulty()
        messageCategory = singleMessageService.getTextCategoryForLevel(level)
        messageText = messageCategory.getRandomText()
        updateMessage()
        super.viewDidLoad()

        /*exampleLabel.textColor = Color.Text
        exampleLabel.layer.backgroundColor = Color.Ciphered.CGColor
        exampleLabel.layer.cornerRadius = 8.0
        exampleLabel.translatesAutoresizingMaskIntoConstraints = false
        exampleLabel.addGradientToLabel(Gradient.Ciphered)*/

        textPreviewLabel.font = UIFont(name: textPreviewLabel.font.fontName, size: 20)
        textPreviewLabel.numberOfLines = 0

        updateSelectedDifficultyInGUI()
    }

    @IBAction func difficultyChanged(sender: AnyObject) {
        selectedDifficulty = cipherDifficulties[difficultySelector.selectedSegmentIndex]
        currentUserService.updateLastSelectedDifficulty(selectedDifficulty)
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
            self.expGainView.runProgress(message.exp)
        }
    }

    private func updateMessage() {
        message = singleMessageService.getMessageForLevel(level, difficulty: selectedDifficulty, text: messageText)
        updateTime()
        //updateMessageExample()
        updateMessageTitle()
        updateMessagePreview()
    }

    private func updateTime() {
        let timer = Timer(seconds: messageCipherService.getTimerSeconds(message))
        startTimerLabel.text = timer.getTimeString()
    }

    private func updateMessageTitle() {
        titleLabel.text = messageCategory.title
    }

    /*private func updateMessageExample() {
        let exampleMessage = messageCipherService.createExampleMessage(
            level.category.cipherType, cipherDifficulty: selectedDifficulty
        )

        exampleLabel.text = exampleMessage.ciphered()
    }*/

    private func updateMessagePreview() {
        textPreviewLabel.text = message.text()
    }

    private func updateSelectedDifficultyInGUI() {
        var index = 0

        for i in 0..<cipherDifficulties.count {
            if (cipherDifficulties[i] == selectedDifficulty) {
                index = i
                break
            }
        }

        difficultySelector.selectedSegmentIndex = index
    }
}
