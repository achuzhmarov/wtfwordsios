import Foundation

class BaseUIViewController: UIViewController {
    private var gradientLayer: CAGradientLayer?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = Color.BackgroundDark
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        updateBackgroundGradient()
    }

    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)

        updateBackgroundGradient()
    }

    func updateBackgroundGradient() {
        if let existsingGradient = gradientLayer {
            existsingGradient.colors = Gradient.Background
            return
        }

        gradientLayer = self.view.addDiagonalGradient(Gradient.Background)
    }

    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}
