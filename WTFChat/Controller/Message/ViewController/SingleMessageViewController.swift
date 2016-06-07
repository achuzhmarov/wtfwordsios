import Foundation

class SingleMessageViewController: BaseMessageViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = talk.users[0].capitalizedString

        dispatch_async(dispatch_get_main_queue(), {
            self.updateView()
        })
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        super.prepareForSegue(segue, sender: sender)

        if segue.identifier == "showDecipher" {
            let targetController = segue.destinationViewController as! DecipherViewController

            let message = sender as! Message

            //TODO - update decipherController for singleMode
            //targetController.message = message
            targetController.talk = talk
        }
    }

    override func updateView() {
        messageTableView.updateTalk(talk)
        messageTableView.scrollTableToBottom()
    }
}
