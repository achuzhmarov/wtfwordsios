import Foundation
import Localize_Swift

class DecipherResultVC: UIViewController, WordTappedComputer {
    let audioService: AudioService = serviceLocator.get(AudioService.self)

    @IBOutlet weak var resultLabel: RoundedLabel!
    @IBOutlet weak var levelView: UIView!
    @IBOutlet weak var wordsTableView: WordsViewController!
    @IBOutlet weak var continueButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var wordsViewHorizontalConstraint: NSLayoutConstraint!

    fileprivate let SUCCESS_TEXT = "Success".localized()
    fileprivate let FAILED_TEXT = "Failed".localized()
    fileprivate let CONTINUE_TEXT = "Continue".localized()
    fileprivate let RETRY_TEXT = "Retry".localized()
    fileprivate let BACK_TEXT = "Back".localized()

    fileprivate var message: Message!

    var expGainView = ExpGainView()

    var parentVC: DecipherViewController {
        return parent as! DecipherViewController
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.clear

        let wordsTap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(DecipherResultVC.viewTapped))
        wordsTableView.addGestureRecognizer(wordsTap)

        wordsTableView.wordTappedComputer = self
        wordsTableView.delegate = wordsTableView
        wordsTableView.dataSource = wordsTableView
        wordsTableView.backgroundColor = UIColor.clear

        resultLabel.layer.cornerRadius = 12
        resultLabel.textColor = Color.Text

        backButton.setTitle(BACK_TEXT, for: UIControlState())
    }

    deinit {
        NotificationCenter.default.removeObserver(self);
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        if (parentVC.resultContainer.isHidden) {
            return
        }

        redrawWordsView(size)

        wordsTableView.alpha = 0
        UIView.animate(withDuration: 0.6, delay: 0,
                options: [], animations: {
            self.wordsTableView.alpha = 1
        }, completion: nil)
    }

    func viewTapped() {
        changeCipherStateForViewOnly()
    }

    @IBAction func backTapped(_ sender: AnyObject) {
        parentVC.backTapped()
    }

    @IBAction func continuePressed(_ sender: AnyObject) {
        parentVC.continuePressed()
    }

    func changeCipherStateForViewOnly() {
        parentVC.useCipherText = !parentVC.useCipherText
        wordsTableView.setNewMessage(message, useCipherText: parentVC.useCipherText, selfAuthor: parentVC.selfAuthor)

        wordsTableView.alpha = 0
        UIView.animate(withDuration: 0.3, delay: 0,
                options: [], animations: {
            self.wordsTableView.alpha = 1
        }, completion: nil)
    }

    fileprivate func redrawWordsView(_ size: CGSize? = nil) {
        let size = size ?? view.frame.size

        wordsTableView.updateMaxWidth(size.width - wordsViewHorizontalConstraint.constant * 2)
        wordsTableView.setNewMessage(message, useCipherText: parentVC.useCipherText, selfAuthor: parentVC.selfAuthor)
    }

    func initView(_ resultMessage: Message) {
        message = resultMessage

        redrawWordsView()
        showResult()

        expGainView.clearView()
        expGainView.initView(levelView)
    }

    func wordTapped(_ word: Word) {
        changeCipherStateForViewOnly()
    }

    func showResult() {
        if (message.getMessageStatus() == .success) {
            resultLabel.text = SUCCESS_TEXT
            resultLabel.addGradientToLabel(Gradient.Success)
            continueButton.setTitle(CONTINUE_TEXT, for: UIControlState())

            audioService.playSound("win")
        } else {
            resultLabel.text = FAILED_TEXT
            resultLabel.addGradientToLabel(Gradient.Failed)
            continueButton.setTitle(RETRY_TEXT, for: UIControlState())

            audioService.playSound("lose")
        }
    }
}
