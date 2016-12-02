import Foundation
import Localize_Swift

class TutorialDecipherInProgressByLettersVC: DecipherInProgressByLettersVC {
    fileprivate let guiDataService: GuiDataService = serviceLocator.get(GuiDataService.self)

    fileprivate let GUESS_MESSAGE = "Let's start! Try to type 'to' and press either 'Try' or 'return' button.".localized()
    fileprivate let CLOSE_TRY_MESSAGE = "Congratulations! Now, enter 'her' as your next guess.".localized()
    fileprivate let CLOSE_TRY_HINT_MESSAGE = "Oh! You were close! See how the word 'He...' has changed color. Try tapping it to decipher!".localized()
    fileprivate let HINT_MESSAGE = "Wow, it worked! Try to use a similar action to get a hint for any blue word.".localized()
    fileprivate let DECIPHER_REST_MESSAGE = "Well done! Now you can decipher the rest of the message by yourself.".localized()

    fileprivate let GUESS_ERROR = "Please, type 'to' and press 'Try'!".localized()
    fileprivate let CLOSE_TRY_ERROR = "Please, type 'her' and press 'Try'!".localized()
    fileprivate let CLOSE_TRY_HINT_ERROR = "Please, tap on the orange word bubble to open it!".localized()
    fileprivate let HINT_ERROR = "Please, tap on any blue word bubble and use a hint!".localized()

    fileprivate let GUESS_TEXT = "TO".localized()
    fileprivate let CLOSE_TRY_TEXT = "HER".localized()

    fileprivate let ZERO_HINTS_TITLE = "WTF remained: 0".localized()
    fileprivate let ZERO_HINTS_MESSAGE = "You have used all WTF.".localized()

    fileprivate let TUTORIAL_HINTS = 3

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        showMessageAlert(GUESS_MESSAGE, tutorialStage: .decipherGuess)
    }

    fileprivate func showWrongActionAlert() {
        switch (guiDataService.getTutorialStageHardcore()) {
        case .decipherGuess:
            showMessageAlert(GUESS_ERROR)
        case .decipherCloseTry:
            showMessageAlert(CLOSE_TRY_ERROR)
        case .decipherCloseTryHint:
            showMessageAlert(CLOSE_TRY_HINT_ERROR)
        case .decipherHint:
            showMessageAlert(HINT_ERROR)
        default: return
        }
    }

    fileprivate func showMessageAlert(_ message: String, tutorialStage: TutorialStageHardcore? = nil) {
        isPaused = true

        WTFOneButtonAlert.show(message, message: "") { () -> Void in
            self.isPaused = false

            if let tutorialStage = tutorialStage {
                self.guiDataService.updateTutorialStageHardcore(tutorialStage)
            }
        }
    }
}
