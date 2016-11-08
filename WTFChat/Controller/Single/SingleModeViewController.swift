import Foundation
import Localize_Swift

class SingleModeViewController: BaseUIViewController {
    fileprivate let singleModeCategoryService: SingleModeCategoryService = serviceLocator.get(SingleModeCategoryService)
    fileprivate let guiDataService: GuiDataService = serviceLocator.get(GuiDataService)
    fileprivate let dailyHintsService: DailyHintsService = serviceLocator.get(DailyHintsService)

    @IBOutlet weak var menuBorder: UIView!
    @IBOutlet weak var menuBackground: UIView!
    @IBOutlet weak var menuButton: MenuButton!
    @IBOutlet weak var pageControlTopPaddingConstraint: NSLayoutConstraint!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var exitGesture: UIGestureRecognizer!

    fileprivate let FINISHED_TITLE = "Congratulations!".localized()
    fileprivate let FINISHED_TEXT = "You have finished the".localized()
    fileprivate let FINISHED_HARD_TEXT = "on hard difficulty.".localized()
    fileprivate let FINISHED_NORMAL_TEXT = "Hard difficulty unlocked.".localized()
    fileprivate let FINISHED_EASY_TEXT = "Complete all levels on Normal difficulty to unlock Hard.".localized()
    fileprivate let NEXT_CHAPTER_TEXT = "Next Chapter".localized()
    fileprivate let STAY_HERE_TEXT = "Stay here".localized()
    fileprivate let MENU_TEXT = "menu".localized()

    fileprivate let PageControlAdditionalPadding: CGFloat = 8

    var handleOffstagePanComputer: ((_ pan: UIPanGestureRecognizer) -> Void)?

    fileprivate var cipherPageViewController: CipherPageViewController!

    fileprivate var currentCipherView: CipherViewController?

    fileprivate let cipherTypes = CipherType.getAll()

    override func viewDidLoad() {
        super.viewDidLoad()

        configurePageControl()

        exitGesture.addTarget(self, action: #selector(SingleModeViewController.handleOffstagePan(_:)))

        menuBorder.backgroundColor = Color.BackgroundDark
        menuBackground.addLinearGradient(Gradient.BackgroundMenu)
        menuButton.setTitle(MENU_TEXT, for: UIControlState())
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        dailyHintsService.computeDailyHints()
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

        if (nextCategory != nil) {
            WTFTwoButtonsAlert.show(FINISHED_TITLE,
                    message: message,
                    firstButtonTitle: NEXT_CHAPTER_TEXT,
                    secondButtonTitle: STAY_HERE_TEXT) { () -> Void in

                self.pageControl.currentPage = self.pageControl.currentPage + 1
                self.cipherPageViewController.showPage(self.pageControl.currentPage)
            }
        } else {
            WTFOneButtonAlert.show(FINISHED_TITLE, message: message)
        }
    }
}
