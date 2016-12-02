import Foundation

class TutorialGameController: GameController {
    var wtf = 99

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
}