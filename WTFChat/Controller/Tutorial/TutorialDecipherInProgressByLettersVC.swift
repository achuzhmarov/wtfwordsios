import Foundation
import Localize_Swift

class TutorialDecipherInProgressByLettersVC: DecipherInProgressByLettersVC {
    private let guiDataService: GuiDataService = serviceLocator.get(GuiDataService.self)

    private let GREETING_MESSAGE = "Hello, in this game you have to decipher texts with the power of your brain!"
    private let FIRST_WORD_MESSAGE = "To begin with, let me give you a hint. The first word is 'Welcome'. Try to enter it with your improvised keyboard."
    private let SELECT_WORD_MESSAGE = "It isn't necessary to solve this text sequentially. Select any word you like from the top part of the screen with a touch."

    private let FIRST_WORD_ERROR = "Please, enter the word 'welcome'.";
    private let SELECT_WORD_ERROR = "Please, select another word at the top part of the screen with a touch."

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
}
