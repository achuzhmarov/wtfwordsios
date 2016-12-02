import Foundation
import Localize_Swift

class TutorialDecipherInProgressByLettersVC: DecipherInProgressByLettersVC {
    private let guiDataService: GuiDataService = serviceLocator.get(GuiDataService.self)

    private let GREETING_MESSAGE = "Hello, in this game you have to decipher texts with the power of your brain!"
    private let FIRST_WORD_MESSAGE = "To begin with, let me give you a hint. The first word is 'Welcome'. Try to enter it with your improvised keyboard."
    private let SELECT_WORD_MESSAGE = "It isn't necessary to solve this text sequentially. Select any word you like from the top part of the screen with a touch."

    private let FIRST_WORD_ERROR = "Please, enter the word 'welcome'.";
    private let SELECT_WORD_ERROR = "Please, select another word at the top part of the screen with a touch."

    private let RUN_OUT_OF_TIME_MESSAGE = "Oh, you have run out of time! But nevermind, it's just a tutorial!";
    private let WTF_POWER_MESSAGE = "Let me introduce you the real power of WTF! You can do almost everything with it. For example, open the next letter!";

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        showMessageAlert(GREETING_MESSAGE, tutorialStage: nil) {
            self.showMessageAlert(self.FIRST_WORD_MESSAGE, tutorialStage: .decipherFirstWord)
        }
    }

    private func showWrongActionAlert() {
        switch (guiDataService.getTutorialStage()) {
        case .decipherFirstWord:
            showMessageAlert(FIRST_WORD_ERROR)
        case .selectAnotherWord:
            showMessageAlert(SELECT_WORD_ERROR)
        default: return
        }
    }

    private func showMessageAlert(_ message: String, tutorialStage: TutorialStage? = nil, completion: (() -> ())? = nil) {
        isPaused = true

        WTFOneButtonAlert.show(message.localized(), message: "") { () -> Void in
            self.isPaused = false

            if let tutorialStage = tutorialStage {
                self.guiDataService.updateTutorialStage(tutorialStage)
            }

            completion?()
        }
    }

    override func useWtf(_ wtf: Int) {
        //do nothing
    }

    override func initGameController() {
        controller = TutorialGameController()
    }

    override func tick() {
        if (timer.seconds < 1) {
            stopTimer()
        } else {
            super.tick()
        }
    }

    private func stopTimer() {
        topTimerLabel.layer.removeAllAnimations()
        topTimerLabel.alpha = 1
        topTimerLabel.textColor = UIColor.black

        timer.seconds = 0
        topTimerLabel.text = timer.getTimeString()

        showMessageAlert(RUN_OUT_OF_TIME_MESSAGE) {
            self.showHint()
        }
    }

    private func showHint() {
        showMessageAlert(WTF_POWER_MESSAGE, tutorialStage: nil) {

        }
    }

    override func setTimer() {
        timer.seconds = 120
        topTimerLabel.text = timer.getTimeString()
    }
}
