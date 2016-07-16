import Foundation

class PassAndPlayDecipherViewController: DecipherViewController {
    private let coreMessageService: CoreMessageService = serviceLocator.get(CoreMessageService)

    private let WORDS_FOR_HINT = 5

    override func calcInitialHints() {
        hints = (message.countNew() - 1) / WORDS_FOR_HINT + 1
    }

    override func showNoHintsDialog() {
        WTFOneButtonAlert.show("Hints remained: 0",
            message: "You have used all hints",
            firstButtonTitle: "Ok",
            viewPresenter: self)
    }

    override func updateHintsUsed() {
        hints -= 1
    }

    override func sendMessageUpdate() {
        coreMessageService.updateMessage(message as! RemoteMessage)
    }

    override func sendMessageDecipher() {
        coreMessageService.updateMessage(message as! RemoteMessage)
    }

    override func showExpView() {
        hideTopLayer()
    }
}
