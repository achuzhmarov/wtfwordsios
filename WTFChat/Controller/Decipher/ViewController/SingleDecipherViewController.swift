import Foundation

class SingleDecipherViewController: BaseDecipherViewController {
    private let singleMessageService: SingleMessageService = serviceLocator.get(SingleMessageService)

    override func sendMessageUpdate() {
        singleMessageService.updateMessage(message as! SingleMessage)
    }

    override func sendMessageDecipher() {
        singleMessageService.decipherMessage(message as! SingleMessage)

        if (message.exp > 0) {
            self.expGainView.runProgress(message.exp)
        }
    }
}
