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

    @IBAction func backTapped(sender: AnyObject) {
        let levelPreviewController = self.presentingViewController as! LevelPreviewViewController
        let singleModeViewController = levelPreviewController.presentingViewController!

        levelPreviewController.view.hidden = true
        levelPreviewController.decipherTransitionManager.animationDuration = 0.3
        levelPreviewController.selfTransitionManager.animationDuration = 0

        levelPreviewController.dismissViewControllerAnimated(true) {
            singleModeViewController.dismissViewControllerAnimated(true, completion: nil)
        }
    }
}
