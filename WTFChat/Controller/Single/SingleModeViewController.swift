import Foundation

class SingleModeViewController: UIViewController {
    @IBOutlet weak var cipherViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var pageControl: UIPageControl!

    private var isInLandscapeMode = false
    private var currentCipherView: CipherViewController?

    private var landscapeCipherHeight: CGFloat = 0
    private var portraitCipherHeight: CGFloat = 0

    private let cipherTypes = CipherType.getAll()

    override func viewDidLoad() {
        super.viewDidLoad()

        configurePageControl()

        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(SingleModeViewController.rotated(_:)),
                name: UIDeviceOrientationDidChangeNotification, object: nil)
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
        pageControl.currentPageIndicatorTintColor = Color.Ciphered
    }

    @IBAction func pageChanged(sender: AnyObject) {
        print(pageControl.currentPage)
    }
}
