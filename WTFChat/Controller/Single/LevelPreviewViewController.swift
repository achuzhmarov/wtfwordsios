import Foundation
import Localize_Swift

class LevelPreviewViewController: BaseModalVC {
    fileprivate let singleMessageService: SingleMessageService = serviceLocator.get(SingleMessageService.self)
    fileprivate let singleModeCategoryService: SingleModeCategoryService = serviceLocator.get(SingleModeCategoryService.self)
    fileprivate let messageCipherService: MessageCipherService = serviceLocator.get(MessageCipherService.self)
    fileprivate let guiDataService: GuiDataService = serviceLocator.get(GuiDataService.self)

    @IBOutlet weak var difficultySelector: UISegmentedControl!
    @IBOutlet weak var startTimerLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var lvlLabel: UILabel!
    @IBOutlet weak var lvlView: UIView!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var backButton: UIButton!

    @IBOutlet weak var messageWordsView: WordsViewController!

    fileprivate let BACK_BUTTON_TITLE = "Back".localized()
    fileprivate let START_BUTTON_TITLE = "Start".localized()

    fileprivate let DECIPHER_SEGUE_ID = "showDecipher"

    fileprivate let cipherDifficulties = CipherDifficulty.getAll()

    var level: Level!
    var message: Message!

    fileprivate var selectedDifficulty = CipherDifficulty.normal

    fileprivate var messageText: String!
    fileprivate var messageCategory: TextCategory!

    let decipherTransitionManager = FadeTransitionManager(duration: 0.5)

    override func viewDidLoad() {
        super.viewDidLoad()

        messageWordsView.dataSource = messageWordsView
        messageWordsView.delegate = messageWordsView
        messageWordsView.backgroundColor = UIColor.clear
        messageWordsView.isHidedText = true
        messageWordsView.fontSize = 12

        selectedDifficulty = guiDataService.getLastSelectedDifficulty()
        checkHardAvailability()

        messageCategory = singleMessageService.getTextCategoryForLevel(level)
        messageText = messageCategory.getMessage()
        updateMessage()

        updateLvlView()

        updateSelectedDifficultyInGUI()

        difficultySelector.setTitle(CipherDifficulty.easy.description, forSegmentAt: CipherDifficulty.easy.rawValue)
        difficultySelector.setTitle(CipherDifficulty.normal.description, forSegmentAt: CipherDifficulty.normal.rawValue)
        difficultySelector.setTitle(CipherDifficulty.hard.description, forSegmentAt: CipherDifficulty.hard.rawValue)

        backButton.setTitle(BACK_BUTTON_TITLE, for: UIControlState())
        startButton.setTitle(START_BUTTON_TITLE, for: UIControlState())
    }

    fileprivate func checkHardAvailability() {
        let hardIndex = CipherDifficulty.hard.rawValue

        if (singleModeCategoryService.isCategoryCleared(level.category, difficulty: .normal)) {
            difficultySelector.setEnabled(true, forSegmentAt: hardIndex)
        } else {
            difficultySelector.setEnabled(false, forSegmentAt: hardIndex)

            if (selectedDifficulty == .hard) {
                selectedDifficulty = .normal
            }
        }
    }

    @IBAction func difficultyChanged(_ sender: AnyObject) {
        selectedDifficulty = cipherDifficulties[difficultySelector.selectedSegmentIndex]
        guiDataService.updateLastSelectedDifficulty(selectedDifficulty)
        updateMessage()
    }

    fileprivate func updateMessage() {
        message = singleMessageService.getMessageForLevel(level, difficulty: selectedDifficulty, text: messageText)
        updateTime()
        updateMessageTitle()
        updateMessagePreview()
    }

    fileprivate func updateTime() {
        let timer = WTFTimer(seconds: messageCipherService.getTimerSeconds(message))
        startTimerLabel.text = timer.getTimeString()
    }

    fileprivate func updateMessageTitle() {
        titleLabel.text = messageCategory.title
    }

    fileprivate func updateMessagePreview() {
        messageWordsView.setNewMessage(message)
    }

    fileprivate func updateSelectedDifficultyInGUI() {
        var index = 0

        for i in 0..<cipherDifficulties.count {
            if (cipherDifficulties[i] == selectedDifficulty) {
                index = i
                break
            }
        }

        difficultySelector.selectedSegmentIndex = index
    }

    fileprivate func updateLvlView() {
        lvlLabel.text = String(level.id)
        lvlView.layer.cornerRadius = 8

        if (level.cleared) {
            let gradient = Gradient.getLevelGradientByDifficulty(level.clearedDifficulty!)
            _ = lvlView.addDiagonalGradient(gradient)
        } else {
            _ = lvlView.addDiagonalGradient(Gradient.Ciphered)
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == DECIPHER_SEGUE_ID {
            let targetController = segue.destination as! SingleDecipherViewController
            targetController.message = message
            targetController.transitioningDelegate = decipherTransitionManager
        }
    }
}
