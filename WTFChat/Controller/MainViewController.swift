import Foundation

class MainViewController: BaseUIViewController {
    private let guiDataService: GuiDataService = serviceLocator.get(GuiDataService)
    private let dailyHintsService: DailyHintsService = serviceLocator.get(DailyHintsService)

    private let TUTORIAL_TITLE = "Tutorial"
    private let TUTORIAL_MESSAGE = "Hi! It is your first time, would you like to start a tutorial?"

    let singleModeTransitionManager = PanTransitionManager()

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        dailyHintsService.computeDailyHints()
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let toViewController = segue.destinationViewController as? SingleModeViewController {
            toViewController.transitioningDelegate = singleModeTransitionManager
            toViewController.handleOffstagePanComputer = self.singleModeTransitionManager.handleOffstagePan
            singleModeTransitionManager.unwindSegue = toViewController.unwindSegue
        }
    }

    private func showTutorialDialog() {
        WTFTwoButtonsAlert.show(TUTORIAL_TITLE,
                message: TUTORIAL_MESSAGE,
                firstButtonTitle: "Start",
                secondButtonTitle: "Skip",
                alertButtonAction: { () -> Void in
                    self.performSegueWithIdentifier("startTutorial", sender: self)
                },
                cancelButtonAction: { () -> Void in
                    self.guiDataService.updateTutorialStage(.Finished)
                    self.performSegueWithIdentifier("startSingleMode", sender: self)
                })
    }

    @IBAction func singleModePressed(sender: AnyObject) {
        if (guiDataService.getTutorialStage() == .Never) {
            showTutorialDialog()
        } else {
            self.performSegueWithIdentifier("startSingleMode", sender: self)
        }
    }

    @IBAction func backToMenu(segue:UIStoryboardSegue) {

    }
}
