import Foundation
import Localize_Swift

class MainViewController: BaseUIViewController {
    private let guiDataService: GuiDataService = serviceLocator.get(GuiDataService)
    private let dailyHintsService: DailyHintsService = serviceLocator.get(DailyHintsService)

    private var TUTORIAL_TITLE: String!
    private var SINGLE_MODE_TITLE: String!
    private var SHOP_TITLE: String!

    private var TUTORIAL_MESSAGE: String!
    private var TUTORIAL_REPEAT_MESSAGE: String!
    private var START_TUTORIAL_TEXT: String!
    private var SKIP_TUTORIAL_TEXT: String!

    @IBOutlet weak var tutorialButton: UIButton!
    @IBOutlet weak var singleModeButton: UIButton!
    @IBOutlet weak var shopButton: UIButton!
    @IBOutlet weak var languageButton: UIButton!

    let singleModeTransitionManager = PanTransitionManager()

    override func viewDidLoad() {
        super.viewDidLoad()

        let currentLanguage = guiDataService.getUserLanguage()
        Localize.setCurrentLanguage(currentLanguage)

        initTitles()
    }

    private func initTitles() {
        initLanguageStrings()

        tutorialButton.setTitle(TUTORIAL_TITLE, forState: .Normal)
        singleModeButton.setTitle(SINGLE_MODE_TITLE, forState: .Normal)
        shopButton.setTitle(SHOP_TITLE, forState: .Normal)

        let currentLanguage = TextLanguage.getCurrentLanguage()
        languageButton.setTitle(currentLanguage.buttonTitle, forState: .Normal)
    }

    private func initLanguageStrings() {
        TUTORIAL_TITLE = "Tutorial".localized()
        SINGLE_MODE_TITLE = "Single mode".localized()
        SHOP_TITLE = "Shop".localized()

        TUTORIAL_MESSAGE = "Hi! It is your first time, would you like to start a tutorial?".localized()
        TUTORIAL_REPEAT_MESSAGE = "You have finished tutorial already, do you want to start it again?".localized()
        START_TUTORIAL_TEXT = "Start".localized()
        SKIP_TUTORIAL_TEXT = "Skip".localized()
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

    @IBAction func tutorialPressed(sender: AnyObject) {
        if (guiDataService.getTutorialStage() == .Never || guiDataService.getTutorialStage() == .Skipped) {
            self.performSegueWithIdentifier("startTutorial", sender: self)
        } else {
            showTutorialConfirmDialog()
        }
    }

    private func showTutorialConfirmDialog() {
        WTFTwoButtonsAlert.show(TUTORIAL_TITLE,
                message: TUTORIAL_REPEAT_MESSAGE,
                firstButtonTitle: START_TUTORIAL_TEXT,
                alertButtonAction: { () -> Void in
                    self.performSegueWithIdentifier("startTutorial", sender: self)
                })
    }

    @IBAction func singleModePressed(sender: AnyObject) {
        if (guiDataService.getTutorialStage() == .Never) {
            showTutorialDialog()
        } else {
            self.performSegueWithIdentifier("startSingleMode", sender: self)
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
                    self.guiDataService.updateTutorialStage(.Skipped)
                    self.performSegueWithIdentifier("startSingleMode", sender: self)
                })
    }

    @IBAction func languageChanged(sender: AnyObject) {
        let currentLanguage = TextLanguage.getNextLanguage()
        Localize.setCurrentLanguage(currentLanguage.description)
        guiDataService.updateUserLanguage(currentLanguage.description)
        initTitles()
    }

    @IBAction func backToMenu(segue:UIStoryboardSegue) {

    }
}
