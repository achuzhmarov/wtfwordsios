import Foundation
import Localize_Swift

class TutorialDecipherVC: DecipherViewController {
    private let guiDataService: GuiDataService = serviceLocator.get(GuiDataService)

    private let TUTORIAL_TITLE = "Welcome".localized()
    private let TUTORIAL_MESSAGE = "Welcome! Glad to see you here. Have a good time!".localized()

    let transitionManager = FadeTransitionManager()

    override func viewDidLoad() {
        message = messageCipherService.createMessage(
                TUTORIAL_MESSAGE,
                cipherType: .RightCutter,
                cipherDifficulty: .Normal
                )

        super.viewDidLoad()

        inProgressVC.topCategoryLabel.text = TUTORIAL_TITLE

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

    private func finishTutorial() {
        let mainVC = self.presentingViewController as! MainViewController
        mainVC.dismissViewControllerAnimated(true, completion: nil)
    }
}
