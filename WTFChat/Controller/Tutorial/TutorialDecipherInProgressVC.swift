import Foundation
import Localize_Swift

class TutorialDecipherInProgressVC: DecipherInProgressVC {
    private let guiDataService: GuiDataService = serviceLocator.get(GuiDataService)

    private let GUESS_MESSAGE = "Let's start! Try to type 'to' and press either 'Try' or 'return' button.".localized()
    private let CLOSE_TRY_MESSAGE = "Congratulations! Now, enter 'her' as your next guess.".localized()
    private let CLOSE_TRY_HINT_MESSAGE = "Oh! You were close! See how the word 'He...' has changed color. Try tapping it to decipher!".localized()
    private let HINT_MESSAGE = "Wow, it worked! Try to use a similar action to get a hint for any blue word.".localized()
    private let DECIPHER_REST_MESSAGE = "Well done! Now you can decipher the rest of the message by yourself.".localized()

    private let GUESS_ERROR = "Please, type 'to' and press 'Try'!".localized()
    private let CLOSE_TRY_ERROR = "Please, type 'her' and press 'Try'!".localized()
    private let CLOSE_TRY_HINT_ERROR = "Please, tap on the orange word bubble to open it!".localized()
    private let HINT_ERROR = "Please, tap on any blue word bubble and use a hint!".localized()

    private let GUESS_TEXT = "TO".localized()
    private let CLOSE_TRY_TEXT = "HER".localized()

    private let ZERO_HINTS_TITLE = "Hints remained: 0".localized()
    private let ZERO_HINTS_MESSAGE = "You have used all hints.".localized()

    private let TUTORIAL_HINTS = 3

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        showMessageAlert(GUESS_MESSAGE, tutorialStage: .DecipherGuess)
    }

    override func showNoHintsDialog() {
        WTFOneButtonAlert.show(ZERO_HINTS_TITLE, message: ZERO_HINTS_MESSAGE)
    }

    override func updateHintsUsed() {
        hints -= 1
    }

    override func updateHintsCount() {
        hints = TUTORIAL_HINTS
    }

    override func tryButtonPressed(sender: AnyObject) {
        switch (guiDataService.getTutorialStage()) {
        case .DecipherGuess:
            if (guessTextField.text!.uppercaseString == GUESS_TEXT) {
                super.tryButtonPressed(sender)
                showMessageAlert(CLOSE_TRY_MESSAGE, tutorialStage: .DecipherCloseTry)
            } else {
                showWrongActionAlert()
            }
        case .DecipherCloseTry:
            if (guessTextField.text!.uppercaseString == CLOSE_TRY_TEXT) {
                super.tryButtonPressed(sender)
                showMessageAlert(CLOSE_TRY_HINT_MESSAGE, tutorialStage: .DecipherCloseTryHint)
            } else {
                showWrongActionAlert()
            }
        case .DecipherCloseTryHint:
            showWrongActionAlert()
        case .DecipherHint:
            showWrongActionAlert()
        default:
            super.tryButtonPressed(sender)
        }
    }

    override func useHint(word: Word) {
        switch (guiDataService.getTutorialStage()) {
        case .DecipherGuess:
            showWrongActionAlert()
        case .DecipherCloseTry:
            showWrongActionAlert()
        case .DecipherCloseTryHint:
            if (word.wasCloseTry) {
                super.useHint(word)
                showMessageAlert(HINT_MESSAGE, tutorialStage: .DecipherHint)
            } else {
                showWrongActionAlert()
            }
        case .DecipherHint:
            super.useHint(word)
            showMessageAlert(DECIPHER_REST_MESSAGE, tutorialStage: .DecipherRest)
        default:
            super.useHint(word)
        }
    }

    private func showWrongActionAlert() {
        switch (guiDataService.getTutorialStage()) {
        case .DecipherGuess:
            showMessageAlert(GUESS_ERROR)
        case .DecipherCloseTry:
            showMessageAlert(CLOSE_TRY_ERROR)
        case .DecipherCloseTryHint:
            showMessageAlert(CLOSE_TRY_HINT_ERROR)
        case .DecipherHint:
            showMessageAlert(HINT_ERROR)
        default: return
        }
    }

    override func giveUpPressed(sender: AnyObject) {
        switch (guiDataService.getTutorialStage()) {
        case .DecipherGuess, .DecipherCloseTry, .DecipherCloseTryHint, .DecipherHint:
            showWrongActionAlert()
        default:
            super.giveUpPressed(sender)
        }
    }

    private func showMessageAlert(message: String, tutorialStage: TutorialStage? = nil) {
        isPaused = true

        WTFOneButtonAlert.show(message, message: "") { () -> Void in
            self.isPaused = false

            if let tutorialStage = tutorialStage {
                self.guiDataService.updateTutorialStage(tutorialStage)
            }
        }
    }
}
