import Foundation
import Localize_Swift

class MainViewController: BaseUIViewController {
    fileprivate let guiDataService: GuiDataService = serviceLocator.get(GuiDataService)
    fileprivate let dailyHintsService: DailyHintsService = serviceLocator.get(DailyHintsService)

    fileprivate var TUTORIAL_TITLE: String!
    fileprivate var SINGLE_MODE_TITLE: String!
    fileprivate var SHOP_TITLE: String!

    fileprivate var TUTORIAL_MESSAGE: String!
    fileprivate var TUTORIAL_REPEAT_MESSAGE: String!
    fileprivate var START_TUTORIAL_TEXT: String!
    fileprivate var SKIP_TUTORIAL_TEXT: String!

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

    fileprivate func initTitles() {
        initLanguageStrings()

        tutorialButton.setTitle(TUTORIAL_TITLE, for: UIControlState())
        singleModeButton.setTitle(SINGLE_MODE_TITLE, for: UIControlState())
        shopButton.setTitle(SHOP_TITLE, for: UIControlState())

        let currentLanguage = TextLanguage.getCurrentLanguage()
        languageButton.setTitle(currentLanguage.buttonTitle, for: UIControlState())
    }

    fileprivate func initLanguageStrings() {
        TUTORIAL_TITLE = "Tutorial".localized()
        SINGLE_MODE_TITLE = "Single mode".localized()
        SHOP_TITLE = "Shop".localized()

        TUTORIAL_MESSAGE = "Hi! It is your first time, would you like to start a tutorial?".localized()
        TUTORIAL_REPEAT_MESSAGE = "You have finished tutorial already, do you want to start it again?".localized()
        START_TUTORIAL_TEXT = "Start".localized()
        SKIP_TUTORIAL_TEXT = "Skip".localized()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        dailyHintsService.computeDailyHints()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let toViewController = segue.destination as? SingleModeViewController {
            toViewController.transitioningDelegate = singleModeTransitionManager
            toViewController.handleOffstagePanComputer = self.singleModeTransitionManager.handleOffstagePan
            singleModeTransitionManager.unwindSegue = toViewController.unwindSegue
        }
    }

    @IBAction func tutorialPressed(_ sender: AnyObject) {
        if (guiDataService.getTutorialStage() == .never || guiDataService.getTutorialStage() == .skipped) {
            self.performSegue(withIdentifier: "startTutorial", sender: self)
        } else {
            showTutorialConfirmDialog()
        }
    }

    fileprivate func showTutorialConfirmDialog() {
        WTFTwoButtonsAlert.show(TUTORIAL_TITLE,
                message: TUTORIAL_REPEAT_MESSAGE,
                firstButtonTitle: START_TUTORIAL_TEXT,
                alertButtonAction: { () -> Void in
                    self.performSegue(withIdentifier: "startTutorial", sender: self)
                })
    }

    @IBAction func singleModePressed(_ sender: AnyObject) {
        if (guiDataService.getTutorialStage() == .never) {
            showTutorialDialog()
        } else {
            self.performSegue(withIdentifier: "startSingleMode", sender: self)
        }
    }

    fileprivate func showTutorialDialog() {
        WTFTwoButtonsAlert.show(TUTORIAL_TITLE,
                message: TUTORIAL_MESSAGE,
                firstButtonTitle: START_TUTORIAL_TEXT,
                secondButtonTitle: SKIP_TUTORIAL_TEXT,
                alertButtonAction: { () -> Void in
                    self.performSegue(withIdentifier: "startTutorial", sender: self)
                },
                cancelButtonAction: { () -> Void in
                    self.guiDataService.updateTutorialStage(.skipped)
                    self.performSegue(withIdentifier: "startSingleMode", sender: self)
                })
    }

    @IBAction func languageChanged(_ sender: AnyObject) {
        let currentLanguage = TextLanguage.getNextLanguage()
        Localize.setCurrentLanguage(currentLanguage.description)
        guiDataService.updateUserLanguage(currentLanguage.description)
        initTitles()
    }

    @IBAction func backToMenu(_ segue:UIStoryboardSegue) {

    }
}
