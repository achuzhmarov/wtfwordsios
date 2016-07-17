import Foundation

class SingleDecipherViewController: DecipherViewController {
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

        topCategoryLabel.text = messageCategory.title

        start()
    }

    override func sendMessageUpdate() {
        //singleMessageService.updateMessage(message as! SingleMessage)
    }

    override func sendMessageDecipher() {
        singleModeService.finishDecipher(singleMessage)
        self.expGainView.runProgress(message.exp)
    }

    @IBAction func backTapped(sender: AnyObject) {
        let levelPreviewController = self.presentingViewController as! LevelPreviewViewController
        let singleModeViewController = levelPreviewController.presentingViewController!

        levelPreviewController.view.hidden = true
        levelPreviewController.decipherTransitionManager.animationDuration = 0.3
        levelPreviewController.selfTransitionManager.animationDuration = 0

        levelPreviewController.dismissViewControllerAnimated(true) {
            singleModeViewController.dismissViewControllerAnimated(true, completion: nil)
        }
    }

    @IBAction func continuePressed(sender: AnyObject) {
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

        setTimer()

        start()
    }

    func startNextLevel(level: Level) {
        print("nextLevel")
    }

    func chapterFinished() {
        print("chapterFinished")
    }
}
