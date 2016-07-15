import Foundation

class MainViewController: BaseUIViewController {

    let navigationDelegate = NavigationControllerDelegate()
    let transitionManager = PanTransitionManager()

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationDelegate.transitionManager = transitionManager
        self.navigationController!.delegate = navigationDelegate
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let toViewController = segue.destinationViewController as? SingleModeViewController {
            //toViewController.transitioningDelegate = self.transitionManager
            toViewController.handleOffstagePanComputer = self.transitionManager.handleOffstagePan
            transitionManager.unwindSegue = toViewController.unwindSegue
        }
    }

    @IBAction func backToMenu(segue:UIStoryboardSegue) {

    }
}
