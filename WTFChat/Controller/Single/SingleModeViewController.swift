import Foundation

class SingleModeViewController: BaseUIViewController {
    private let singleModeCategoryService: SingleModeCategoryService = serviceLocator.get(SingleModeCategoryService)
    private let guiDataService: GuiDataService = serviceLocator.get(GuiDataService)
    private let dailyHintsService: DailyHintsService = serviceLocator.get(DailyHintsService)

    @IBOutlet weak var menuBorder: UIView!
    @IBOutlet weak var menuBackground: UIView!
    @IBOutlet weak var pageControlTopPaddingConstraint: NSLayoutConstraint!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var exitGesture: UIGestureRecognizer!

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

            message = "You have finished the" + " \"" + currentCategory.cipherType.description + "\" " + "on hard difficulty."
        } else if (currentCategory.hasJustClearedOnNormal) {
            currentCategory.hasJustClearedOnNormal = false

            message = "You have finished the" + " \"" + currentCategory.cipherType.description + "\". " + "Hard difficulty unlocked."
        } else if (currentCategory.hasJustClearedOnEasy) {
            currentCategory.hasJustClearedOnEasy = false

            message = "You have finished the" + " \"" + currentCategory.cipherType.description + "\". " + "Complete all levels on Normal difficulty to unlock Hard."
        } else {
            //no need for alert
            return
        }

        if (nextCategory != nil) {
            WTFTwoButtonsAlert.show("Congratulations!",
                    message: message,
                    firstButtonTitle: "Next Chapter",
                    secondButtonTitle: "Stay here") { () -> Void in

                self.pageControl.currentPage = self.pageControl.currentPage + 1
                self.cipherPageViewController.showPage(self.pageControl.currentPage)
            }
        } else {
            WTFOneButtonAlert.show("Congratulations!", message: message, firstButtonTitle: "Ok")
        }
    }
}
