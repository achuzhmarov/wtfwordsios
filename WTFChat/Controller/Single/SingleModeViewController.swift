import Foundation

class SingleModeViewController: BaseUIViewController {
    @IBOutlet weak var menuBorder: UIView!
    @IBOutlet weak var menuBackground: UIView!
    @IBOutlet weak var pageControlTopPaddingConstraint: NSLayoutConstraint!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var exitGesture: UIGestureRecognizer!

    private let PageControlAdditionalPadding: CGFloat = 8
    private let DECIPHER_SEGUE_ID = "showDecipher"

    var handleOffstagePanComputer: ((pan: UIPanGestureRecognizer) -> Void)?

    private var cipherPageViewController: CipherPageViewController!

    private var currentCipherView: CipherViewController?

    private let cipherTypes = CipherType.getAll()

    private var messageForDecipher: Message?

    override func viewDidLoad() {
        super.viewDidLoad()

        configurePageControl()

        cipherPageViewController.view.backgroundColor = UIColor.clearColor()

        exitGesture.addTarget(self, action: #selector(SingleModeViewController.handleOffstagePan(_:)))

        menuBorder.backgroundColor = Color.BackgroundDark
        menuBackground.addLinearGradient(Gradient.BackgroundMenu)
    }

    func cipherViewUpdated(newController: CipherViewController) {
        currentCipherView = newController
        configurePageControl()
    }

    private func configurePageControl() {
        pageControl.numberOfPages = cipherTypes.count
        pageControl.currentPage = currentCipherView?.activeCipherIndex ?? 0
        pageControl.pageIndicatorTintColor = UIColor.blackColor()
        pageControl.currentPageIndicatorTintColor = Color.CipheredDark
    }

    @IBAction func pageChanged(sender: AnyObject) {
        cipherPageViewController.showPage(pageControl.currentPage)
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let cipherPageViewController = segue.destinationViewController as? CipherPageViewController {
            self.cipherPageViewController = cipherPageViewController
        } else if segue.identifier == DECIPHER_SEGUE_ID {
            let targetController = segue.destinationViewController as! SingleDecipherViewController
            targetController.message = messageForDecipher
        }
    }

    func unwindSegue() {
        self.performSegueWithIdentifier("backToMenu", sender: self)
    }

    func handleOffstagePan(pan: UIPanGestureRecognizer) {
        handleOffstagePanComputer?(pan: pan)
    }

    @IBAction func startDecipher(segue:UIStoryboardSegue) {
        if let levelPreviewViewController = segue.sourceViewController as? LevelPreviewViewController {
            messageForDecipher = levelPreviewViewController.message
            levelPreviewViewController.dismissViewControllerAnimated(false, completion: nil)
            self.performSegueWithIdentifier(DECIPHER_SEGUE_ID, sender: self)
        }
    }

    @IBAction func backToCiphers(segue:UIStoryboardSegue) {

    }
}
