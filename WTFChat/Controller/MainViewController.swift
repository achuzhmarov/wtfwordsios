import Foundation

class MainViewController: BaseUIViewController {

    let transitionManager = PanTransitionManager()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.navigationBarHidden = true
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let toViewController = segue.destinationViewController as? SingleModeViewController {
            toViewController.transitioningDelegate = self.transitionManager
            toViewController.handleOffstagePanComputer = self.transitionManager.handleOffstagePan
            self.transitionManager.unwindSegue = toViewController.unwindSegue
        }
    }

    @IBAction func backToMenu(segue:UIStoryboardSegue) {

    }
}
