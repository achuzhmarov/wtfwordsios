import Foundation

class TutorialDecipherResultVC: DecipherResultVC {
    private let guiDataService: GuiDataService = serviceLocator.get(GuiDataService)

    private let FINISH_BUTTON_TITLE = "Finish"
    private let FINISH_MESSAGE = "You have finished tutorial! Also you can tap the message area to see its ciphered form."

    override func showResult() {
        super.showResult()

        continueButton.setTitle(FINISH_BUTTON_TITLE, forState: .Normal)

        WTFOneButtonAlert.show(FINISH_MESSAGE,
                message: "",
                firstButtonTitle: "Ok", viewPresenter: self) { () -> Void in
            self.guiDataService.updateTutorialStage(.Finished)
        }
    }
}