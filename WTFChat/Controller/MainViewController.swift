import Foundation

class MainViewController: BaseUIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.navigationBarHidden = true
    }

    @IBAction func backToMenu(segue:UIStoryboardSegue) {

    }
}
