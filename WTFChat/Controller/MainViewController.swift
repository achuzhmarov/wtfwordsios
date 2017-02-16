import Foundation
import Localize_Swift

class MainViewController: BaseFullVC {
    private let guiDataService: GuiDataService = serviceLocator.get(GuiDataService.self)
    private let dailyHintsService: DailyHintsService = serviceLocator.get(DailyHintsService.self)
    private let personalRewardService: PersonalRewardService = serviceLocator.get(PersonalRewardService.self)
    private let textCategoryService: TextCategoryService = serviceLocator.get(TextCategoryService.self)
    private let inAppService: InAppService = serviceLocator.get(InAppService.self)

    private let TUTORIAL_TITLE = "Tutorial"
    private let SINGLE_MODE_TITLE = "Single mode"
    private let SHOP_TITLE = "Shop"
    private let SALE_TITLE = "SALE"
    private let SOUND_TITLE = "Sound"
    private let SOUND_OFF = "Off"
    private let SOUND_ON = "On"
    private let FEEDBACK_TITLE = "Give Feedback"

    private let TUTORIAL_MESSAGE = "Hi! It is your first time, would you like to start a tutorial?"
    private let TUTORIAL_REPEAT_MESSAGE = "You have finished tutorial already, do you want to start it again?"
    private let START_TUTORIAL_TEXT = "Start"
    private let SKIP_TUTORIAL_TEXT = "Skip"

    @IBOutlet weak var tutorialButton: UIButton!
    @IBOutlet weak var singleModeButton: UIButton!
    @IBOutlet weak var shopButton: BorderedButton!
    @IBOutlet weak var languageButton: UIButton!
    @IBOutlet weak var soundButton: UIButton!
    @IBOutlet weak var feedbackButton: UIButton!

    let singleModeTransitionManager = PanTransitionManager()

    private var timer: Timer?

    override func viewDidLoad() {
        super.viewDidLoad()

        let currentLanguage = guiDataService.getUserLanguage()
        Localize.setCurrentLanguage(currentLanguage)

        initTitles()
    }

    private func initTitles() {
        tutorialButton.setTitleWithoutAnimation(TUTORIAL_TITLE.localized())
        singleModeButton.setTitleWithoutAnimation(SINGLE_MODE_TITLE.localized())
        setShopButtonTitle()
        setSoundButtonTitle()
        feedbackButton.setTitleWithoutAnimation(FEEDBACK_TITLE.localized())

        let currentLanguage = TextLanguage.getCurrentLanguage()
        languageButton.setTitleWithoutAnimation(currentLanguage.buttonTitle)

        setTitlesUpdateTimer()
    }

    private func setSoundButtonTitle() {
        var title = SOUND_TITLE.localized() + ": "

        if (guiDataService.isSoundOn()) {
            title += SOUND_ON.localized()
        } else {
            title += SOUND_OFF.localized()
        }

        soundButton.setTitleWithoutAnimation(title)
    }

    private func setShopButtonTitle() {
        var title = SHOP_TITLE.localized()

        if (inAppService.isSaleOn()) {
            title += ": " + inAppService.getSaleCoeff() + " " + SALE_TITLE.localized() + "!"
            shopButton.setTitleWithoutAnimation(title)
            shopButton.updateGradient(Gradient.Try)
        } else {
            shopButton.setTitleWithoutAnimation(title)
            shopButton.updateGradient(Gradient.Ciphered)
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        initTitles()
        dailyHintsService.computeDailyWtf()
        personalRewardService.checkPersonalReward()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        stopTitlesUpdateTimer()
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

    private func showTutorialConfirmDialog() {
        WTFTwoButtonsAlert.show(TUTORIAL_TITLE.localized(),
                message: TUTORIAL_REPEAT_MESSAGE.localized(),
                firstButtonTitle: START_TUTORIAL_TEXT.localized(),
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

    private func showTutorialDialog() {
        WTFTwoButtonsAlert.show(TUTORIAL_TITLE.localized(),
                message: TUTORIAL_MESSAGE.localized(),
                firstButtonTitle: START_TUTORIAL_TEXT.localized(),
                secondButtonTitle: SKIP_TUTORIAL_TEXT.localized(),
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
        textCategoryService.loadTextsForLanguage(currentLanguage)
        initTitles()
    }

    @IBAction func soundStateChanged(_ sender: AnyObject) {
        let newSoundState = !guiDataService.isSoundOn()
        guiDataService.updateSoundState(newSoundState)
        initTitles()
    }

    @IBAction func backToMenu(_ segue:UIStoryboardSegue) {

    }

    private func setTitlesUpdateTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(timeInterval: 1.0,
                target: self,
                selector: #selector(self.updateTimerTick),
                userInfo: nil,
                repeats: true)
    }

    private func stopTitlesUpdateTimer() {
        timer?.invalidate()
    }

    @objc func updateTimerTick() {
        DispatchQueue.main.async(execute: {
            self.initTitles()
        })
    }
}
