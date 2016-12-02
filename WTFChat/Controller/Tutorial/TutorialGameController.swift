import Foundation

class TutorialGameController: GameController {
    private let guiDataService: GuiDataService = serviceLocator.get(GuiDataService.self)

    private let SELECT_WORD_ERROR = "Please, select another word at the top part of the screen with a touch."

    private var wtf = 99

    var showErrorMessageAlert: ((_: String) -> ())!

    override func showHintConfirmAlert(_ hintType: HintType, completion: @escaping () -> ()) {
        showHintConfirm(wtf: wtf, hintType: hintType, completion: completion)
    }

    override func showHintConfirm(wtf: Int, hintType: HintType, completion: @escaping () -> () ) {
        WTFTwoButtonsAlert.show("WTF remained:".localized() + " " + String(wtf),
                message: hintType.details.localized(),
                firstButtonTitle: "Use".localized() + " " + String(hintType.costInWtf) + " " + "WTF".localized()) { () -> Void in

            DispatchQueue.main.async(execute: {
                self.wtf -= hintType.costInWtf
                completion()
            })
        }
    }

    @objc override func tileTapped(_ sender: UITapGestureRecognizer) {
        switch (guiDataService.getTutorialStage()) {
        case .selectAnotherWord:
            showErrorMessageAlert(SELECT_WORD_ERROR)
        default:
            super.tileTapped(sender)
        }
    }
}