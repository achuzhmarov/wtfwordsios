import Foundation

class DecipherViewController: BaseUIViewController {
    let messageCipherService: MessageCipherService = serviceLocator.get(MessageCipherService.self)

    var message: Message!

    @IBOutlet weak var inProgressContainer: UIView!
    @IBOutlet weak var inProgressByLettersContainer: UIView!
    @IBOutlet weak var resultContainer: UIView!

    var inProgressVC: DecipherInProgressVC!
    var inProgressByLettersVC: DecipherInProgressByLettersVC!
    var resultVC: DecipherResultVC!

    //for viewOnly mode
    var useCipherText = false
    var selfAuthor = false

    override func viewDidLoad() {
        super.viewDidLoad()

        view.setNeedsLayout()
        view.layoutIfNeeded()

        resultContainer.isHidden = true
        inProgressContainer.isHidden = true
        inProgressByLettersContainer.isHidden = true

        //inProgressVC.initView(message)
        inProgressByLettersVC.initView(message)
        inProgressVC.initView(message)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? DecipherInProgressVC {
            inProgressVC = vc
        } else if let vc = segue.destination as? DecipherResultVC {
            resultVC = vc
        } else if let vc = segue.destination as? DecipherInProgressByLettersVC {
            inProgressByLettersVC = vc
        }
    }

    func startHardcore() {
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

    func start() {
        inProgressByLettersContainer.isHidden = false

        resultContainer.isHidden = true
        view.bringSubview(toFront: inProgressByLettersContainer)

        inProgressByLettersVC.initView(message)
        inProgressVC.initView(message)
        inProgressByLettersVC.start()

        UIView.setAnimationsEnabled(true)

        inProgressByLettersContainer.alpha = 0

        UIView.animate(withDuration: 0.5, delay: 0,
                options: [], animations: {
            self.inProgressByLettersContainer.alpha = 1
        }, completion: nil)
    }

    func gameOver() {
        inProgressContainer.isHidden = true
        inProgressByLettersContainer.isHidden = true
        resultContainer.isHidden = false
        view.bringSubview(toFront: resultContainer)

        //message = inProgressVC.message
        message = inProgressByLettersVC.message

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
        inProgressByLettersVC.hintsBought()
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

    override func motionEnded(_ motion: UIEventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            inProgressByLettersVC.wasShaked()
        }
    }
}
