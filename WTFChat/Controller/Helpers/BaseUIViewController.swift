import Foundation

class BaseUIViewController: UIViewController {
    private var baseIsInLandscapeMode = false
    private var gradientLayer: CAGradientLayer?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = Color.BackgroundDark

        if (UIDeviceOrientationIsLandscape(UIDevice.currentDevice().orientation)) {
            baseIsInLandscapeMode = true
        } else {
            baseIsInLandscapeMode = false
        }

        updateBackgroundGradient()

        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(BaseUIViewController.baseRotated(_:)),
                name: UIDeviceOrientationDidChangeNotification, object: nil)
    }

    func baseRotated(notification: NSNotification) {
        if (UIDeviceOrientationIsLandscape(UIDevice.currentDevice().orientation)) {
            if (!baseIsInLandscapeMode) {
                baseIsInLandscapeMode = true
                updateBackgroundGradient()
            }
        } else if(UIDeviceOrientationIsPortrait(UIDevice.currentDevice().orientation)) {
            if (baseIsInLandscapeMode) {
                baseIsInLandscapeMode = false
                updateBackgroundGradient()
            }
        }
    }

    func updateBackgroundGradient() {
        gradientLayer?.removeFromSuperlayer()
        gradientLayer = self.view.addGradient(Gradient.Background)
    }
}
