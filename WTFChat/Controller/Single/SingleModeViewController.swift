import Foundation

class SingleModeViewController: BaseUIViewController {
    @IBOutlet weak var cipherViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var pageControl: UIPageControl!
    private var cipherPageViewController: CipherPageViewController!

    private var isInLandscapeMode = false
    private var currentCipherView: CipherViewController?

    private var landscapeCipherHeight: CGFloat = 0
    private var portraitCipherHeight: CGFloat = 0

    private let cipherTypes = CipherType.getAll()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.setHidesBackButton(true, animated:true)

        configurePageControl()

        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(SingleModeViewController.rotated(_:)),
                name: UIDeviceOrientationDidChangeNotification, object: nil)

        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(SingleModeViewController.swipeLeft(_:)))
        swipeLeft.direction = .Left
        self.view.addGestureRecognizer(swipeLeft)

        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(SingleModeViewController.swipeRight(_:)))
        swipeRight.direction = .Right
        self.view.addGestureRecognizer(swipeRight)

        cipherPageViewController.view.backgroundColor = UIColor.clearColor()
    }

    func cipherViewUpdated(newController: CipherViewController) {
        currentCipherView = newController
        updateCipherViewHeight()
        configurePageControl()
    }

    func updateCipherViewHeight() {
        if (isInLandscapeMode) {
            updateLandscapeCipherHeightIfNeeded()
            cipherViewHeightConstraint.constant = landscapeCipherHeight
        } else {
            updatePortraitCipherHeightIfNeeded()
            cipherViewHeightConstraint.constant = portraitCipherHeight
        }
    }

    private func updateLandscapeCipherHeightIfNeeded() {
        if landscapeCipherHeight == 0 {
            landscapeCipherHeight = currentCipherView!.getFullHeight()
        }
    }

    private func updatePortraitCipherHeightIfNeeded() {
        if portraitCipherHeight == 0 {
            portraitCipherHeight = currentCipherView!.getFullHeight()
        }
    }

    func rotated(notification: NSNotification) {
        if (UIDeviceOrientationIsLandscape(UIDevice.currentDevice().orientation)) {
            if (!isInLandscapeMode) {
                isInLandscapeMode = true
                updateCipherViewHeight()
            }
        } else if(UIDeviceOrientationIsPortrait(UIDevice.currentDevice().orientation)) {
            if (isInLandscapeMode) {
                isInLandscapeMode = false
                updateCipherViewHeight()
            }
        }

        view.setNeedsLayout()
        view.layoutIfNeeded()
    }

    private func configurePageControl() {
        pageControl.numberOfPages = cipherTypes.count
        pageControl.currentPage = currentCipherView?.activeCipherIndex ?? 0
        //pageControl.tintColor = UIColor.redColor()
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

    func swipeLeft(gesture: UIGestureRecognizer) {
        let nextPage = pageControl.currentPage + 1
        if (nextPage < cipherTypes.count) {
            cipherPageViewController.showPage(nextPage)
        }
    }

    func swipeRight(gesture: UIGestureRecognizer) {
        let prevPage = pageControl.currentPage - 1
        if (prevPage >= 0) {
            cipherPageViewController.showPage(prevPage)
        }
    }

    func respondToSwipeGesture(gesture: UIGestureRecognizer) {
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            switch swipeGesture.direction {
            case UISwipeGestureRecognizerDirection.Left:
                let nextPage = pageControl.currentPage + 1
                if (nextPage < cipherTypes.count) {
                    cipherPageViewController.showPage(nextPage)
                }
            case UISwipeGestureRecognizerDirection.Right:
                let prevPage = pageControl.currentPage - 1
                if (prevPage >= 0) {
                    cipherPageViewController.showPage(prevPage)
                }
            default:
                break
            }
        }
    }
}
