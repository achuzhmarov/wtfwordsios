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

        view.setNeedsLayout()
        view.layoutIfNeeded()

        resultContainer.isHidden = true

        inProgressVC.initView(message)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? DecipherInProgressVC {
            inProgressVC = vc
        } else if let vc = segue.destination as? DecipherResultVC {
            resultVC = vc
        }
    }

    func start() {
        inProgressContainer.isHidden = false
        resultContainer.isHidden = true
        view.bringSubview(toFront: inProgressContainer)

        inProgressVC.initView(message)
        inProgressVC.start()

        UIView.setAnimationsEnabled(true)

        inProgressContainer.alpha = 0

        UIView.animate(withDuration: 0.5, delay: 0,
                options: [], animations: {
            self.inProgressContainer.alpha = 1
        }, completion: nil)
    }

    func gameOver() {
        inProgressContainer.isHidden = true
        resultContainer.isHidden = false
        view.bringSubview(toFront: resultContainer)

        message = inProgressVC.message
        messageCipherService.failed(message)

        resultVC.initView(message)

        UIView.setAnimationsEnabled(true)

        resultContainer.alpha = 0

        UIView.animate(withDuration: 0.5, delay: 0,
                options: [], animations: {
            self.resultContainer.alpha = 1
        }, completion: nil)

        sendMessageDecipher()
    }

    func hintsBought() {
        inProgressVC.hintsBought()
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
