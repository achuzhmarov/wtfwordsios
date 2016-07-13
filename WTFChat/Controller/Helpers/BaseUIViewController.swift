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

        updateBackgroundGradient(size)

        /*coordinator.animateAlongsideTransition(nil, completion: { context in
            self.updateBackgroundGradient(size)
        })*/
    }

    func updateBackgroundGradient(size: CGSize? = nil) {
        gradientLayer?.removeFromSuperlayer()
        gradientLayer = self.view.addDiagonalGradient(Gradient.Background, size: size)
    }

    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}
