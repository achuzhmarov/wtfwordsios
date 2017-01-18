import Foundation
import Localize_Swift

class SingleModeViewController: BaseUIViewController {
    private let singleModeCategoryService: SingleModeCategoryService = serviceLocator.get(SingleModeCategoryService.self)
    private let guiDataService: GuiDataService = serviceLocator.get(GuiDataService.self)
    private let dailyHintsService: DailyHintsService = serviceLocator.get(DailyHintsService.self)

    @IBOutlet weak var menuBorder: UIView!
    @IBOutlet weak var menuBackground: UIView!
    @IBOutlet weak var menuButton: MenuButton!
    @IBOutlet weak var pageControlTopPaddingConstraint: NSLayoutConstraint!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var exitGesture: UIGestureRecognizer!

    private let FINISHED_TITLE = "Congratulations!".localized()
    private let FINISHED_TEXT = "You have finished the".localized()
    private let FINISHED_HARD_TEXT = "on hard difficulty.".localized()
    private let FINISHED_NORMAL_TEXT = "Hard difficulty unlocked.".localized()
    private let FINISHED_EASY_TEXT = "Complete all levels on Normal difficulty to unlock Hard.".localized()
    private let NEXT_CHAPTER_TEXT = "Next Chapter".localized()
    private let STAY_HERE_TEXT = "Stay here".localized()
    private let MENU_TEXT = "menu".localized()

    private let PageControlAdditionalPadding: CGFloat = 8

    var handleOffstagePanComputer: ((_ pan: UIPanGestureRecognizer) -> Void)?

    private var cipherPageViewController: CipherPageViewController!

    private var currentCipherView: CipherViewController?

    private let cipherTypes = CipherType.getAll()

    override func viewDidLoad() {
        super.viewDidLoad()

        configurePageControl()

        exitGesture.addTarget(self, action: #selector(SingleModeViewController.handleOffstagePan(_:)))

        menuBorder.backgroundColor = Color.BackgroundDark
        _ = menuBackground.addLinearGradient(Gradient.BackgroundMenu)
        menuButton.setTitleWithoutAnimation(MENU_TEXT)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        dailyHintsService.computeDailyWtf()
    }

    func cipherViewUpdated(_ newController: CipherViewController) {
        currentCipherView = newController
        configurePageControl()
    }

    fileprivate func configurePageControl() {
        pageControl.numberOfPages = cipherTypes.count
        pageControl.currentPage = currentCipherView?.activeCipherIndex ?? guiDataService.getLastSelectedCategoryType().rawValue
        pageControl.pageIndicatorTintColor = UIColor.black
        pageControl.currentPageIndicatorTintColor = Color.CipheredDark
    }

    @IBAction func pageChanged(_ sender: AnyObject) {
        cipherPageViewController.showPage(pageControl.currentPage)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let cipherPageViewController = segue.destination as? CipherPageViewController {
            self.cipherPageViewController = cipherPageViewController
        }
    }

    func unwindSegue() {
        self.performSegue(withIdentifier: "backToMenu", sender: self)
    }

    func handleOffstagePan(_ pan: UIPanGestureRecognizer) {
        handleOffstagePanComputer?(pan)
    }

    func reloadData() {
        cipherPageViewController.reloadData()
    }

    func checkCategoryCleared() {
        let currentCategory = currentCipherView!.getCurrentCategory()
        let nextCategory = singleModeCategoryService.getNextCategory(currentCategory)

        var message = ""

        if (currentCategory.hasJustClearedOnHard) {
            currentCategory.hasJustClearedOnHard = false

            message = FINISHED_TEXT + " \"" + currentCategory.cipherType.description + "\" " + FINISHED_HARD_TEXT
        } else if (currentCategory.hasJustClearedOnNormal) {
            currentCategory.hasJustClearedOnNormal = false

            message = FINISHED_TEXT + " \"" + currentCategory.cipherType.description + "\". " + FINISHED_NORMAL_TEXT
        } else if (currentCategory.hasJustClearedOnEasy) {
            currentCategory.hasJustClearedOnEasy = false

            message = FINISHED_TEXT + " \"" + currentCategory.cipherType.description + "\". " + FINISHED_EASY_TEXT
        } else {
            //no need for alert
            return
        }

        DispatchQueue.main.async {
            if (nextCategory != nil) {
                WTFTwoButtonsAlert.show(self.FINISHED_TITLE,
                        message: message,
                        firstButtonTitle: self.NEXT_CHAPTER_TEXT,
                        secondButtonTitle: self.STAY_HERE_TEXT,
                        viewPresenter: self) { () -> Void in

                    self.pageControl.currentPage = self.pageControl.currentPage + 1
                    self.cipherPageViewController.showPage(self.pageControl.currentPage)
                }
            } else {
                WTFOneButtonAlert.show(self.FINISHED_TITLE, message: message, viewPresenter: self)
            }
        }
    }
}
