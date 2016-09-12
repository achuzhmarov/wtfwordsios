import Foundation
import Localize_Swift

class MainViewController: BaseUIViewController {
    private let guiDataService: GuiDataService = serviceLocator.get(GuiDataService)
    private let dailyHintsService: DailyHintsService = serviceLocator.get(DailyHintsService)

    private let TUTORIAL_TITLE = "Tutorial".localized()
    private let SINGLE_MODE_TITLE = "Single mode".localized()
    private let SHOP_TITLE = "Shop".localized()

    private let TUTORIAL_MESSAGE = "Hi! It is your first time, would you like to start a tutorial?".localized()
    private let START_TUTORIAL_TEXT = "Start".localized()
    private let SKIP_TUTORIAL_TEXT = "Skip".localized()

    @IBOutlet weak var tutorialButton: UIButton!
    @IBOutlet weak var singleModeButton: UIButton!
    @IBOutlet weak var shopButton: UIButton!

    let singleModeTransitionManager = PanTransitionManager()

    override func viewDidLoad() {
        super.viewDidLoad()

        tutorialButton.setTitle(TUTORIAL_TITLE, forState: .Normal)
        singleModeButton.setTitle(SINGLE_MODE_TITLE, forState: .Normal)
        shopButton.setTitle(SHOP_TITLE, forState: .Normal)
    }

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
                firstButtonTitle: START_TUTORIAL_TEXT,
                secondButtonTitle: SKIP_TUTORIAL_TEXT,
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
