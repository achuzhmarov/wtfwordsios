import Foundation

class BaseMessageViewController: UIViewController, MessageTappedComputer, UITextViewDelegate {
    @IBOutlet weak var messageTableView: MessageTableView!

    var talk: Talk!
    var firstTimeLoaded = true

    override func viewDidLoad() {
        super.viewDidLoad()

        self.messageTableView.delegate = self.messageTableView
        self.messageTableView.dataSource = self.messageTableView
        self.messageTableView.rowHeight = UITableViewAutomaticDimension
        self.messageTableView.messageTappedComputer = self

        self.messageTableView.alpha = 0
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        if (talk.messages.count > 0) {
            self.updateView()

            if (self.messageTableView.alpha == 0) {
                firstTimeLoaded = false

                let delay = Double(talk.messages.count) / 200.0
                showMessages(0.5, delay: delay)
            }
        }
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        if (firstTimeLoaded) {
            firstTimeLoaded = false

            showMessages(0.3, delay: 0)
        }
    }

    private func showMessages(duration: NSTimeInterval, delay: NSTimeInterval) {
        UIView.animateWithDuration(duration, delay: delay,
                options: [], animations: {
            self.messageTableView.alpha = 1
        }, completion: nil)
    }

    //MessageTappedComputer delegate
    func messageTapped(message: Message) {
        performSegueWithIdentifier("showDecipher", sender: message)
    }

    func updateView() {
        fatalError("This method must be overridden")
    }
}
