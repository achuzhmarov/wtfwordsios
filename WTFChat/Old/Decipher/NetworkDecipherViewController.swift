import UIKit

class NetworkDecipherViewController: DecipherViewController {
    /*private let messageService: MessageService = serviceLocator.get(MessageService)

    override func viewDidLoad() {
        super.viewDidLoad()

        if (message.deciphered || selfAuthor) {
            setViewOnlyStage()
        } else {
            UIView.animateWithDuration(1, delay: 0,
                    options: [.Repeat, .Autoreverse], animations: {
                self.startView?.alpha = 0
            }, completion: nil)
        }
    }

    override func sendMessageUpdate() {
        messageService.decipherMessage(message as! RemoteMessage) { (message, error) -> Void in
            if let requestError = error {
                print(requestError)
            }
        }
    }
    
    override func sendMessageDecipher() {
        messageService.decipherMessageInTalk(message as! RemoteMessage)

        messageService.decipherMessage(message as! RemoteMessage) { (message, error) -> Void in
            dispatch_async(dispatch_get_main_queue(), {
                if let requestError = error {
                    print(requestError)
                } else {
                    if (message!.exp > 0) {
                        self.expGainView.runProgress(message!.exp)
                    }
                }
            })
        }
    }

    override func viewTapped() {
        super.viewTapped()

        if (!isStarted) {
            start()
        }
    }*/
}
