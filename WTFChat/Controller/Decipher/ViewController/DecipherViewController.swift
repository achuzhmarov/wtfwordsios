import Foundation

class DecipherViewController: BaseUIViewController {
    let messageCipherService: MessageCipherService = serviceLocator.get(MessageCipherService)

    var message: Message!

    @IBOutlet weak var inProgressContainer: UIView!
    @IBOutlet weak var resultContainer: UIView!

    var inProgressVC: DecipherInProgressVC!
    var resultVC: DecipherResultVC!

    //for viewOnly mode
    var useCipherText = false
    var selfAuthor = false

    override func viewDidLoad() {
        super.viewDidLoad()

        resultContainer.hidden = true

        inProgressVC.initView(message)
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let vc = segue.destinationViewController as? DecipherInProgressVC {
            inProgressVC = vc
        } else if let vc = segue.destinationViewController as? DecipherResultVC {
            resultVC = vc
        }
    }

    func start() {
        inProgressContainer.hidden = false
        resultContainer.hidden = true
        view.bringSubviewToFront(inProgressContainer)

        inProgressVC.initView(message)
        inProgressVC.start()

        UIView.setAnimationsEnabled(true)

        inProgressContainer.alpha = 0

        UIView.animateWithDuration(0.5, delay: 0,
                options: [], animations: {
            self.inProgressContainer.alpha = 1
        }, completion: nil)
    }

    func gameOver() {
        inProgressContainer.hidden = true
        resultContainer.hidden = false
        view.bringSubviewToFront(resultContainer)

        message = inProgressVC.message
        messageCipherService.failed(message)

        sendMessageDecipher()

        resultVC.initView(message)

        UIView.setAnimationsEnabled(true)

        resultContainer.alpha = 0

        UIView.animateWithDuration(0.5, delay: 0,
                options: [], animations: {
            self.resultContainer.alpha = 1
        }, completion: nil)
    }

    func sendMessageDecipher() {
        fatalError("This method must be overridden")
    }

    func sendMessageUpdate() {
        fatalError("This method must be overridden")
    }

    func backTapped() {
        fatalError("This method must be overridden")
    }

    func continuePressed() {
        fatalError("This method must be overridden")
    }
}
