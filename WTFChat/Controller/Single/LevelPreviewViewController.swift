import Foundation

class LevelPreviewViewController: BaseUIViewController {
    private let singleMessageService: SingleMessageService = serviceLocator.get(SingleMessageService)
    private let messageCipherService: MessageCipherService = serviceLocator.get(MessageCipherService)
    private let currentUserService: CurrentUserService = serviceLocator.get(CurrentUserService)

    @IBOutlet weak var difficultySelector: UISegmentedControl!
    @IBOutlet weak var startTimerLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var textPreviewLabel: UILabel!

    private let DECIPHER_SEGUE_ID = "showDecipher"

    private let cipherDifficulties = CipherDifficulty.getAll()
    private var selectedDifficulty = CipherDifficulty.Normal

    var level: Level!
    private var messageText: String!
    private var messageCategory: TextCategory!
    private var message: Message!

    override func viewDidLoad() {
        super.viewDidLoad()

        selectedDifficulty = currentUserService.getLastSelectedDifficulty()
        messageCategory = singleMessageService.getTextCategoryForLevel(level)
        messageText = messageCategory.getRandomText()
        updateMessage()

        textPreviewLabel.font = UIFont(name: textPreviewLabel.font.fontName, size: 20)
        textPreviewLabel.numberOfLines = 0

        updateSelectedDifficultyInGUI()
    }

    @IBAction func difficultyChanged(sender: AnyObject) {
        selectedDifficulty = cipherDifficulties[difficultySelector.selectedSegmentIndex]
        currentUserService.updateLastSelectedDifficulty(selectedDifficulty)
        updateMessage()
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == DECIPHER_SEGUE_ID {
            let targetController = segue.destinationViewController as! SingleDecipherViewController
            targetController.message = message
        }
    }

    private func updateMessage() {
        message = singleMessageService.getMessageForLevel(level, difficulty: selectedDifficulty, text: messageText)
        updateTime()
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
