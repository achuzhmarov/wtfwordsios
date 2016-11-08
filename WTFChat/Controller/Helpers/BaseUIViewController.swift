import Foundation

class BaseUIViewController: UIViewController {
    fileprivate var gradientLayer: CAGradientLayer?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = Color.BackgroundDark
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        updateBackgroundGradient()
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        updateBackgroundGradient(size)

        /*coordinator.animateAlongsideTransition(nil, completion: { context in
            self.updateBackgroundGradient(size)
        })*/
    }

    func updateBackgroundGradient(_ size: CGSize? = nil) {
        gradientLayer?.removeFromSuperlayer()
        gradientLayer = self.view.addDiagonalGradient(Gradient.Background, size: size)
    }

    override var prefersStatusBarHidden : Bool {
        return true
    }
}
