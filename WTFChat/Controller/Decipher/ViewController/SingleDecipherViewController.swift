import Foundation

class SingleDecipherViewController: DecipherViewController {
    private let currentUserService: CurrentUserService = serviceLocator.get(CurrentUserService)
    private let singleModeService: SingleModeService = serviceLocator.get(SingleModeService)
    //private let singleModeCategoryService: SingleModeCategoryService = serviceLocator.get(SingleModeCategoryService)
    private let singleMessageService: SingleMessageService = serviceLocator.get(SingleMessageService)
    private let levelService: LevelService = serviceLocator.get(LevelService)

    private var singleMessage: SingleMessage!
    private var messageCategory: TextCategory!

    override func viewDidLoad() {
        super.viewDidLoad()

        singleMessage = message as! SingleMessage
        messageCategory = singleMessageService.getTextCategoryForLevel(singleMessage.level)

        inProgressVC.topCategoryLabel.text = messageCategory.title

        start()
    }

    override func sendMessageUpdate() {
        //singleMessageService.updateMessage(message as! SingleMessage)
    }

    override func sendMessageDecipher() {
        singleModeService.finishDecipher(singleMessage)
        resultVC.expGainView.runProgress(message.exp)
    }

    override func backTapped() {
        let levelPreviewController = self.presentingViewController as! LevelPreviewViewController
        let singleModeViewController = levelPreviewController.presentingViewController!

        levelPreviewController.view.hidden = true
        levelPreviewController.decipherTransitionManager.animationDuration = 0.3
        levelPreviewController.selfTransitionManager.animationDuration = 0

        singleModeViewController

        levelPreviewController.dismissViewControllerAnimated(true) {
            singleModeViewController.dismissViewControllerAnimated(true, completion: nil)
        }
    }

    override func continuePressed() {
        if (message.getMessageStatus() == .Failed) {
            restartCurrentLevel()
        } else if let nextLevel = levelService.getNextLevel(singleMessage.level) {
            startNextLevel(nextLevel)
        } else {
            chapterFinished()
        }
    }

    func restartCurrentLevel() {
        let selectedDifficulty = currentUserService.getLastSelectedDifficulty()
        let messageText = messageCategory.getRandomText()

        message = singleMessageService.getMessageForLevel(
            singleMessage.level, difficulty: selectedDifficulty, text: messageText
        )

        start()
    }

    func startNextLevel(level: Level) {
        let selectedDifficulty = currentUserService.getLastSelectedDifficulty()

        messageCategory = singleMessageService.getTextCategoryForLevel(level)
        let messageText = messageCategory.getRandomText()

        message = singleMessageService.getMessageForLevel(
            singleMessage.level, difficulty: selectedDifficulty, text: messageText
        )

        inProgressVC.topCategoryLabel.text = messageCategory.title

        start()
    }

    func chapterFinished() {
        print("chapterFinished")
    }
}
