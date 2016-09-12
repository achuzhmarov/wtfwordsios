import Foundation
import Localize_Swift

class TutorialDecipherResultVC: DecipherResultVC {
    private let guiDataService: GuiDataService = serviceLocator.get(GuiDataService)

    private let FINISH_BUTTON_TITLE = "Finish".localized()
    private let FINISH_MESSAGE = "You have finished tutorial! Also you can tap the message area to see its ciphered form.".localized()

    override func showResult() {
        super.showResult()

        continueButton.setTitle(FINISH_BUTTON_TITLE, forState: .Normal)

        WTFOneButtonAlert.show(FINISH_MESSAGE,
                message: "",
                viewPresenter: self) { () -> Void in
            self.guiDataService.updateTutorialStage(.Finished)
        }
    }
}