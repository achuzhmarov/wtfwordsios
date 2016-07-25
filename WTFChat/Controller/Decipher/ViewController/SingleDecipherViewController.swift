import Foundation

class SingleDecipherViewController: DecipherViewController {
    private let guiDataService: GuiDataService = serviceLocator.get(GuiDataService)
    private let singleModeService: SingleModeService = serviceLocator.get(SingleModeService)
    private let singleMessageService: SingleMessageService = serviceLocator.get(SingleMessageService)
    private let levelService: LevelService = serviceLocator.get(LevelService)
    private let currentUserService: CurrentUserService = serviceLocator.get(CurrentUserService)

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
        let previousUserLvl = currentUserService.getUserLvl()

        singleModeService.finishDecipher(singleMessage)
        resultVC.expGainView.runProgress(message.exp)
        messageCategory.updateMessage()

        let currentUserLvl = currentUserService.getUserLvl()

        if (currentUserLvl > previousUserLvl) {
            let hintsForLvl = currentUserService.addHintsForLvlUp()

            let title = "Level " + String(currentUserLvl) + "!"
            let message = "You got " + String(hintsForLvl) + " free hints"

            WTFOneButtonAlert.show(title,
                    message: message,
                    firstButtonTitle: "Ok",
                    viewPresenter: self)
        }
    }

    override func backTapped() {
        let levelPreviewVC = self.presentingViewController as! LevelPreviewViewController
        let singleModeVC = levelPreviewVC.presentingViewController as! SingleModeViewController

        singleModeVC.reloadData()

        levelPreviewVC.view.hidden = true
        levelPreviewVC.decipherTransitionManager.animationDuration = 0.3
        levelPreviewVC.transitionManager.animationDuration = 0

        levelPreviewVC.dismissViewControllerAnimated(true) {
            singleModeVC.dismissViewControllerAnimated(true) {
                singleModeVC.checkCategoryCleared()
            }
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
        let selectedDifficulty = guiDataService.getLastSelectedDifficulty()
        let messageText = messageCategory.getMessage()

        message = singleMessageService.getMessageForLevel(
            singleMessage.level, difficulty: selectedDifficulty, text: messageText
        )

        start()
    }

    func startNextLevel(level: Level) {
        let selectedDifficulty = guiDataService.getLastSelectedDifficulty()

        messageCategory = singleMessageService.getTextCategoryForLevel(level)
        let messageText = messageCategory.getMessage()

        message = singleMessageService.getMessageForLevel(
            singleMessage.level, difficulty: selectedDifficulty, text: messageText
        )

        inProgressVC.topCategoryLabel.text = messageCategory.title

        start()
    }

    func chapterFinished() {
        backTapped()
    }
}
