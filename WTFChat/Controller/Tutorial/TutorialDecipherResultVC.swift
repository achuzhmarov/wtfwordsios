import Foundation
import Localize_Swift

class TutorialDecipherResultVC: DecipherResultVC {
    fileprivate let guiDataService: GuiDataService = serviceLocator.get(GuiDataService.self)

    fileprivate let FINISH_BUTTON_TITLE = "Finish".localized()
    fileprivate let FINISH_MESSAGE = "You have finished tutorial! Also you can tap the message area to see its ciphered form.".localized()

    override func showResult() {
        super.showResult()

        continueButton.setTitle(FINISH_BUTTON_TITLE, for: UIControlState())

        WTFOneButtonAlert.show(FINISH_MESSAGE,
                message: "",
                viewPresenter: self) { () -> Void in
            self.guiDataService.updateTutorialStageHardcore(.finished)
        }
    }
}
