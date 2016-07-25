import Foundation

class MainViewController: BaseUIViewController {
    private let dailyHintsService: DailyHintsService = serviceLocator.get(DailyHintsService)

    let transitionManager = PanTransitionManager()

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        dailyHintsService.computeDailyHints()
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let toViewController = segue.destinationViewController as? SingleModeViewController {
            toViewController.transitioningDelegate = transitionManager
            toViewController.handleOffstagePanComputer = self.transitionManager.handleOffstagePan
            transitionManager.unwindSegue = toViewController.unwindSegue
        }
    }

    @IBAction func tutorialTapped(sender: AnyObject) {
        WTFOneButtonAlert.show("Under development",
                message: nil,
                firstButtonTitle: "Ok")
    }

    @IBAction func backToMenu(segue:UIStoryboardSegue) {

    }
}
