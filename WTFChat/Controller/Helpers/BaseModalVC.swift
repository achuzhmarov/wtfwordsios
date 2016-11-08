import Foundation

class BaseModalVC: UIViewController {
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var backgroundViewWidthConstraint: NSLayoutConstraint!

    fileprivate var gradientLayer: CAGradientLayer?

    let transitionManager = FadeTransitionManager()

    weak var presentingVC: UIViewController?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.transitioningDelegate = transitionManager

        view.setNeedsLayout()
        view.layoutIfNeeded()

        backgroundView.layer.cornerRadius = 12
        backgroundView.layer.masksToBounds = true

        updateBackgroundGradient()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        presentingVC = presentingViewController
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        updateBackgroundGradient()
    }

    fileprivate func updateBackgroundGradient() {
        gradientLayer?.removeFromSuperlayer()

        let size = CGSize(
                width: backgroundViewWidthConstraint.constant,
                height: backgroundView.frame.size.height
                )

        gradientLayer = backgroundView.addDiagonalGradient(Gradient.Background, size: size)
    }

    @IBAction func closeWindow(_ sender: AnyObject) {
        modalWillClose()
        presentingViewController?.dismiss(animated: true, completion: modalClosed)
    }

    func modalWillClose() {
        //do nothing by default
    }

    func modalClosed() {
        //do nothing by default
    }
}
