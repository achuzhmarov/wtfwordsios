import Foundation

class SingleDecipherViewController: BaseDecipherViewController {
    private let singleMessageService: SingleMessageService = serviceLocator.get(SingleMessageService)
    private let singleModeService: SingleModeService = serviceLocator.get(SingleModeService)

    override func sendMessageUpdate() {
        singleMessageService.updateMessage(message as! SingleMessage)
    }

    override func sendMessageDecipher() {
        let singleMessage = message as! SingleMessage

        singleModeService.finishDecipher(singleMessage)

        if (message.exp > 0) {
            let starStatus = singleModeService.getStarStatus(singleMessage)
            self.expGainView.runProgress(message.exp, starStatus: starStatus)
        }
    }
}
