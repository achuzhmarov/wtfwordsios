import Foundation
import Localize_Swift

class TutorialDecipherResultVC: DecipherResultVC {
    private let FINISH_BUTTON_TITLE = "Finish"
    private let FINISH_MESSAGE = "You have finished tutorial! Also you can tap the message area to see its ciphered form."

    override func showResult() {
        super.showResult()

        continueButton.setTitle(FINISH_BUTTON_TITLE.localized(), for: UIControlState())

        WTFOneButtonAlert.show(FINISH_MESSAGE.localized(),
                message: "",
                viewPresenter: self) { () -> Void in
            self.guiDataService.updateTutorialStage(.finished)
        }
    }
}
