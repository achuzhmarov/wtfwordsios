import Foundation

class SingleDecipherViewController: BaseDecipherViewController {
    private let singleModeService: SingleModeService = serviceLocator.get(SingleModeService)

    override func viewDidLoad() {
        super.viewDidLoad()

        start()
    }

    override func sendMessageUpdate() {
        //singleMessageService.updateMessage(message as! SingleMessage)
    }

    override func sendMessageDecipher() {
        let singleMessage = message as! SingleMessage

        singleModeService.finishDecipher(singleMessage)

        self.expGainView.runProgress(message.exp)

        /*if (message.exp > 0) {
            self.expGainView.runProgress(message.exp)
        }*/
    }
}
