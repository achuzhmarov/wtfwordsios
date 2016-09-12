import Foundation
import Localize_Swift

class SingleModeViewController: BaseUIViewController {
    private let singleModeCategoryService: SingleModeCategoryService = serviceLocator.get(SingleModeCategoryService)
    private let guiDataService: GuiDataService = serviceLocator.get(GuiDataService)
    private let dailyHintsService: DailyHintsService = serviceLocator.get(DailyHintsService)

    @IBOutlet weak var menuBorder: UIView!
    @IBOutlet weak var menuBackground: UIView!
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

    private let PageControlAdditionalPadding: CGFloat = 8

    var handleOffstagePanComputer: ((pan: UIPanGestureRecognizer) -> Void)?

    private var cipherPageViewController: CipherPageViewController!

    private var currentCipherView: CipherViewController?

    private let cipherTypes = CipherType.getAll()

    override func viewDidLoad() {
        super.viewDidLoad()

        configurePageControl()

        exitGesture.addTarget(self, action: #selector(SingleModeViewController.handleOffstagePan(_:)))

        menuBorder.backgroundColor = Color.BackgroundDark
        menuBackground.addLinearGradient(Gradient.BackgroundMenu)
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        dailyHintsService.computeDailyHints()
    }

    func cipherViewUpdated(newController: CipherViewController) {
        currentCipherView = newController
        configurePageControl()
    }

    private func configurePageControl() {
        pageControl.numberOfPages = cipherTypes.count
        pageControl.currentPage = currentCipherView?.activeCipherIndex ?? guiDataService.getLastSelectedCategoryType().rawValue
        pageControl.pageIndicatorTintColor = UIColor.blackColor()
        pageControl.currentPageIndicatorTintColor = Color.CipheredDark
    }

    @IBAction func pageChanged(sender: AnyObject) {
        cipherPageViewController.showPage(pageControl.currentPage)
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let cipherPageViewController = segue.destinationViewController as? CipherPageViewController {
            self.cipherPageViewController = cipherPageViewController
        }
    }

    func unwindSegue() {
        self.performSegueWithIdentifier("backToMenu", sender: self)
    }

    func handleOffstagePan(pan: UIPanGestureRecognizer) {
        handleOffstagePanComputer?(pan: pan)
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
