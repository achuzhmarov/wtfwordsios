import Foundation
import Localize_Swift

class SingleDecipherViewController: DecipherViewController {
    fileprivate let guiDataService: GuiDataService = serviceLocator.get(GuiDataService.self)
    fileprivate let singleModeService: SingleModeService = serviceLocator.get(SingleModeService.self)
    fileprivate let singleMessageService: SingleMessageService = serviceLocator.get(SingleMessageService.self)
    fileprivate let levelService: LevelService = serviceLocator.get(LevelService.self)
    fileprivate let currentUserService: CurrentUserService = serviceLocator.get(CurrentUserService.self)
    fileprivate let ratingService: RatingService = serviceLocator.get(RatingService.self)

    fileprivate let LEVEL_TEXT = "Level".localized()
    fileprivate let GOT_HINTS_BEGIN_TEXT = "You got".localized()
    fileprivate let GOT_HINTS_END_TEXT = "free WTFs".localized()

    fileprivate var singleMessage: SingleMessage!
    fileprivate var messageCategory: TextCategory!

    override func viewDidLoad() {
        super.viewDidLoad()

        singleMessage = message as! SingleMessage
        messageCategory = singleMessageService.getTextCategoryForLevel(singleMessage.level)

        //inProgressVC.topCategoryLabel.text = messageCategory.title
        inProgressByLettersVC.topCategoryLabel.text = messageCategory.title

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
            let hintsForLvl = currentUserService.addWtfsForLvlUp()

            let title = LEVEL_TEXT + " " + String(currentUserLvl) + "!"
            let message = GOT_HINTS_BEGIN_TEXT + " " + String(hintsForLvl) + " " + GOT_HINTS_END_TEXT

            WTFOneButtonAlert.show(title, message: message, viewPresenter: self) {
                if (self.singleMessage.getMessageStatus() == .success) {
                    self.ratingService.askUserForAppRate()
                }
            }
        }
    }

    override func backTapped() {
        let levelPreviewVC = self.presentingViewController as! LevelPreviewViewController
        let singleModeVC = levelPreviewVC.presentingViewController as! SingleModeViewController

        singleModeVC.reloadData()

        levelPreviewVC.view.isHidden = true
        levelPreviewVC.decipherTransitionManager.animationDuration = 0.3
        levelPreviewVC.transitionManager.animationDuration = 0

        levelPreviewVC.dismiss(animated: true) {
            singleModeVC.dismiss(animated: true) {
                singleModeVC.checkCategoryCleared()
            }
        }
    }

    override func continuePressed() {
        if (message.getMessageStatus() == .failed) {
            restartCurrentLevel()
        } else if let nextLevel = levelService.getNextLevel(singleMessage.level) {
            startNextLevel(nextLevel)
        } else {
            chapterFinished()
        }
    }

    func restartCurrentLevel() {
        let messageText = messageCategory.getMessage()

        singleMessage = singleMessageService.getMessageForLevel(
            singleMessage.level, difficulty: singleMessage.cipherDifficulty, text: messageText
        )
        message = singleMessage

        start()
    }

    func startNextLevel(_ level: Level) {
        messageCategory = singleMessageService.getTextCategoryForLevel(level)
        let messageText = messageCategory.getMessage()

        singleMessage = singleMessageService.getMessageForLevel(
            level, difficulty: singleMessage.cipherDifficulty, text: messageText
        )
        message = singleMessage

        //inProgressVC.topCategoryLabel.text = messageCategory.title
        inProgressByLettersVC.topCategoryLabel.text = messageCategory.title

        start()
    }

    func chapterFinished() {
        backTapped()
    }
}
