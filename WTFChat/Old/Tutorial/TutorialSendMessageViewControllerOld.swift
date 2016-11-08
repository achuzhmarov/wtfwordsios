import Foundation

class TutorialSendMessageViewControllerOld: SendMessageViewController {
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if (currentTutorialStage == .sendMessage) {
            WTFOneButtonAlert.show("Choose a cipher",
                message: "You can now choose cipher type and difficulty to cipher your message. Try different ones and see how your message transforms. Make a choice and press 'Send' button at the top right corner.",
                firstButtonTitle: "Ok") { () -> Void in
                    currentTutorialStage = .selectCipher
            }
        }
    }
    
    override func sendTapped(_ sender: AnyObject) {
        if (currentTutorialStage == .selectCipher) {
            currentTutorialStage = .messageSended
        }
        
        super.sendTapped(sender)
    }
}
