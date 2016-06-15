import Foundation

class SingleMessageViewController: BaseMessageViewController {
    /*private let singleMessageService: SingleMessageService = serviceLocator.get(SingleMessageService)

    var singleTalk: SingleTalk!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.singleTalk = talk as! SingleTalk

        self.title = singleTalk.cipherType.description + " - " + singleTalk.cipherDifficulty.description

        addNewMessageToTalkIfAllDeciphered()

        dispatch_async(dispatch_get_main_queue(), {
            self.updateView()
        })
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        super.prepareForSegue(segue, sender: sender)

        UIHelper.clearBackButton(navigationItem)

        if segue.identifier == "showDecipher" {
            let targetController = segue.destinationViewController as! SingleDecipherViewController

            let message = sender as! Message
            targetController.message = message
        }
    }

    override func updateView() {
        addNewMessageToTalkIfAllDeciphered()

        messageTableView.updateTalk(talk)
        messageTableView.scrollTableToBottom()
    }

    private func addNewMessageToTalkIfAllDeciphered() {
        if let lastMessage = self.singleTalk.messages.last {
            if lastMessage.deciphered {
                singleMessageService.generateNewMessageForTalk(singleTalk)
            }
        } else {
            singleMessageService.generateNewMessageForTalk(singleTalk)
        }
    }*/
}
