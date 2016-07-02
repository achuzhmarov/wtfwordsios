import Foundation

class BaseUIViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = UIColor.whiteColor()

        self.view.addGradient(Gradient.Background)
    }
}
