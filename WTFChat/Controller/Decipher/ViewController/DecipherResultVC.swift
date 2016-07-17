import Foundation

class DecipherResultVC: UIViewController, HintComputer {
    let audioService: AudioService = serviceLocator.get(AudioService)

    @IBOutlet weak var resultLabel: RoundedLabel!

    @IBOutlet weak var levelView: UIView!

    @IBOutlet weak var wordsTableView: WordsViewController!

    @IBOutlet weak var continueButton: UIButton!

    let SUCCESS_TEXT = "Success"
    let FAILED_TEXT = "Failed"

    private var message: Message!

    var expGainView = ExpGainView()

    var parent: DecipherViewController {
        return parentViewController as! DecipherViewController
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.clearColor()

        let wordsTap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(DecipherResultVC.viewTapped))
        wordsTableView.addGestureRecognizer(wordsTap)

        wordsTableView.hintComputer = self
        wordsTableView.delegate = wordsTableView
        wordsTableView.dataSource = wordsTableView
        wordsTableView.backgroundColor = UIColor.clearColor()

        resultLabel.layer.cornerRadius = 12
        resultLabel.textColor = Color.Text
    }

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self);
    }

    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)

        redrawWordsView()
    }

    func viewTapped() {
        changeCipherStateForViewOnly()
    }

    @IBAction func backTapped(sender: AnyObject) {
        parent.backTapped()
    }

    @IBAction func continuePressed(sender: AnyObject) {
        parent.continuePressed()
    }

    func changeCipherStateForViewOnly() {
        parent.useCipherText = !parent.useCipherText
        wordsTableView.setNewMessage(message, useCipherText: parent.useCipherText, selfAuthor: parent.selfAuthor)
    }

    private func redrawWordsView() {
        wordsTableView.updateMaxWidth()
        wordsTableView.setNewMessage(message)
        //wordsTableView.setNewMessage(message, useCipherText: useCipherText, selfAuthor: selfAuthor)
    }

    func initView(resultMessage: Message) {
        message = resultMessage

        wordsTableView.updateMessage(message)
        showResult()

        expGainView.clearView()
        expGainView.initView(levelView)
    }

    func hintTapped(word: Word) {
        changeCipherStateForViewOnly()
    }

    private func showResult() {
        if (message.getMessageStatus() == .Success) {
            resultLabel.text = SUCCESS_TEXT
            resultLabel.addGradientToLabel(Gradient.Success)
            continueButton.setTitle("Continue", forState: .Normal)

            audioService.playSound("win")
        } else {
            resultLabel.text = FAILED_TEXT
            resultLabel.addGradientToLabel(Gradient.Failed)
            continueButton.setTitle("Retry", forState: .Normal)

            audioService.playSound("lose")
        }
    }
}
