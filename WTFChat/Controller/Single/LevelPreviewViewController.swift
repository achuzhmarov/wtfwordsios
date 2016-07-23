import Foundation

class LevelPreviewViewController: BaseModalVC {
    private let singleMessageService: SingleMessageService = serviceLocator.get(SingleMessageService)
    private let singleModeCategoryService: SingleModeCategoryService = serviceLocator.get(SingleModeCategoryService)
    private let messageCipherService: MessageCipherService = serviceLocator.get(MessageCipherService)
    private let guiDataService: GuiDataService = serviceLocator.get(GuiDataService)

    @IBOutlet weak var difficultySelector: UISegmentedControl!
    @IBOutlet weak var startTimerLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var lvlLabel: UILabel!
    @IBOutlet weak var lvlView: UIView!

    @IBOutlet weak var messageWordsView: WordsViewController!

    private let DECIPHER_SEGUE_ID = "showDecipher"

    private let cipherDifficulties = CipherDifficulty.getAll()

    var level: Level!
    var message: Message!

    private var selectedDifficulty = CipherDifficulty.Normal

    private var messageText: String!
    private var messageCategory: TextCategory!

    let decipherTransitionManager = FadeTransitionManager(duration: 0.5)

    override func viewDidLoad() {
        super.viewDidLoad()

        messageWordsView.dataSource = messageWordsView
        messageWordsView.delegate = messageWordsView
        messageWordsView.backgroundColor = UIColor.clearColor()
        messageWordsView.isHidedText = true
        messageWordsView.fontSize = 12

        selectedDifficulty = guiDataService.getLastSelectedDifficulty()
        checkHardAvailability()

        messageCategory = singleMessageService.getTextCategoryForLevel(level)
        messageText = messageCategory.getMessage()
        updateMessage()

        updateLvlView()

        updateSelectedDifficultyInGUI()
    }

    private func checkHardAvailability() {
        let hardIndex = CipherDifficulty.Hard.rawValue

        if (singleModeCategoryService.isCategoryCleared(level.category, difficulty: .Normal)) {
            difficultySelector.setEnabled(true, forSegmentAtIndex: hardIndex)
        } else {
            difficultySelector.setEnabled(false, forSegmentAtIndex: hardIndex)

            if (selectedDifficulty == .Hard) {
                selectedDifficulty = .Normal
            }
        }
    }

    @IBAction func difficultyChanged(sender: AnyObject) {
        selectedDifficulty = cipherDifficulties[difficultySelector.selectedSegmentIndex]
        guiDataService.updateLastSelectedDifficulty(selectedDifficulty)
        updateMessage()
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
        messageWordsView.setNewMessage(message)
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

    private func updateLvlView() {
        lvlLabel.text = String(level.id)
        lvlView.layer.cornerRadius = 8

        if (level.cleared) {
            let gradient = Gradient.getLevelGradientByDifficulty(level.clearedDifficulty!)
            lvlView.addDiagonalGradient(gradient)
        } else {
            lvlView.addDiagonalGradient(Gradient.Ciphered)
        }
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == DECIPHER_SEGUE_ID {
            let targetController = segue.destinationViewController as! SingleDecipherViewController
            targetController.message = message
            targetController.transitioningDelegate = decipherTransitionManager
        }
    }
}
