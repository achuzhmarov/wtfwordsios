import Foundation

class TutorialSendMessageViewControllerOld: SendMessageViewController {
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if (currentTutorialStage == .SendMessage) {
            WTFOneButtonAlert.show("Choose a cipher",
                message: "You can now choose cipher type and difficulty to cipher your message. Try different ones and see how your message transforms. Make a choice and press 'Send' button at the top right corner.",
                firstButtonTitle: "Ok") { () -> Void in
                    currentTutorialStage = .SelectCipher
            }
        }
    }
    
    override func sendTapped(sender: AnyObject) {
        if (currentTutorialStage == .SelectCipher) {
            currentTutorialStage = .MessageSended
        }
        
        super.sendTapped(sender)
    }
}