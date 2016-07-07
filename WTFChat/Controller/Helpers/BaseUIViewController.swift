import Foundation

class BaseUIViewController: UIViewController {
    private var baseIsInLandscapeMode = false
    private var gradientLayer: CAGradientLayer?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = Color.BackgroundDark

        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(BaseUIViewController.baseRotated(_:)),
                name: UIDeviceOrientationDidChangeNotification, object: nil)
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        computeOrientation()
    }

    func baseRotated(notification: NSNotification) {
        if (UIDeviceOrientationIsLandscape(UIDevice.currentDevice().orientation)) {
            if (!baseIsInLandscapeMode) {
                computeOrientation()
            }
        } else if(UIDeviceOrientationIsPortrait(UIDevice.currentDevice().orientation)) {
            if (baseIsInLandscapeMode) {
                computeOrientation()
            }
        }
    }

    func computeOrientation() {
        if (UIDeviceOrientationIsLandscape(UIDevice.currentDevice().orientation)) {
            baseIsInLandscapeMode = true
        } else {
            baseIsInLandscapeMode = false
        }

        updateBackgroundGradient()
    }

    func updateBackgroundGradient() {
        gradientLayer?.removeFromSuperlayer()
        gradientLayer = self.view.addDiagonalGradient(Gradient.Background)
    }

    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}
