import Foundation
import Localize_Swift

class TutorialDecipherVC: DecipherViewController {
    fileprivate let guiDataService: GuiDataService = serviceLocator.get(GuiDataService.self)

    fileprivate let TUTORIAL_TITLE = "Welcome"
    fileprivate let TUTORIAL_MESSAGE = "Welcome! Glad to see you here. Have a good time!"

    let transitionManager = FadeTransitionManager()

    override func viewDidLoad() {
        message = messageCipherService.createMessage(
                TUTORIAL_MESSAGE.localized(),
                cipherType: .rightCutter,
                cipherDifficulty: .normal
                )

        super.viewDidLoad()

        inProgressByLettersVC.topCategoryLabel.text = TUTORIAL_TITLE.localized()

        start()

        self.transitioningDelegate = transitionManager
    }

    override func sendMessageUpdate() {
        //do nothing
    }

    override func sendMessageDecipher() {
        //do nothing
    }

    override func continuePressed() {
        finishTutorial()
    }

    fileprivate func finishTutorial() {
        let mainVC = self.presentingViewController as! MainViewController
        mainVC.dismiss(animated: true, completion: nil)
    }
}
