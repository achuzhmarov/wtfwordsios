import Foundation
import Localize_Swift

class DecipherInProgressVC: UIViewController {
    let currentUserService: CurrentUserService = serviceLocator.get(CurrentUserService.self)
    let messageCipherService: MessageCipherService = serviceLocator.get(MessageCipherService.self)
    let audioService: AudioService = serviceLocator.get(AudioService.self)

    @IBOutlet weak var topTimerLabel: UILabel!
    @IBOutlet weak var topCategoryLabel: UILabel!
    @IBOutlet weak var topStopImage: UIImageView!
    @IBOutlet weak var topGiveUpView: UIView!

    @IBOutlet weak var wordsTableView: WordsViewController!

    @IBOutlet weak var guessTextField: UITextField!

    @IBOutlet weak var tryButton: UIButton!

    @IBOutlet weak var bottomViewConstraint: NSLayoutConstraint!
    @IBOutlet weak var topPaddingConstraint: NSLayoutConstraint!
    @IBOutlet weak var wordsViewHorizontalConstraint: NSLayoutConstraint!

    fileprivate let GIVE_UP_TITLE_TEXT = "Stop deciphering?".localized()
    fileprivate let GIVE_UP_BUTTON_TEXT = "Give Up".localized()
    fileprivate let TRY_TEXT = "Try".localized()
    fileprivate let GUESS_PLACEHOLDER_TEXT = "Enter your guess here".localized()

    var message: Message!

    var isPaused = false
    var timer = WTFTimer()

    var wtfs = 0

    var initialTopPaddingConstraintConstant: CGFloat = 0

    var parentVC: DecipherViewController {
        return parent as! DecipherViewController
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.clear

        initialTopPaddingConstraintConstant = topPaddingConstraint.constant

        NotificationCenter.default.addObserver(self, selector: #selector(DecipherInProgressVC.keyboardWillShow(_:)), name:NSNotification.Name.UIKeyboardWillShow, object: nil);
        NotificationCenter.default.addObserver(self, selector: #selector(DecipherInProgressVC.keyboardWillHide(_:)), name:NSNotification.Name.UIKeyboardWillHide, object: nil);

        let giveUpTap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(DecipherInProgressVC.giveUpPressed))
        topTimerLabel.addGestureRecognizer(giveUpTap)
        topStopImage.addGestureRecognizer(giveUpTap)
        topGiveUpView.addGestureRecognizer(giveUpTap)

        wordsTableView.wordTappedComputer = self
        wordsTableView.delegate = wordsTableView
        wordsTableView.dataSource = wordsTableView
        wordsTableView.backgroundColor = UIColor.clear

        guessTextField.delegate = self
        guessTextField.autocorrectionType = .no

        layoutTopView()

        tryButton.setTitle(TRY_TEXT, for: UIControlState())

        let placeholder = NSAttributedString(string: GUESS_PLACEHOLDER_TEXT, attributes: [NSForegroundColorAttributeName : UIColor.lightGray])
        guessTextField.attributedPlaceholder = placeholder
    }

    deinit {
        NotificationCenter.default.removeObserver(self);
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        isPaused = false
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        isPaused = true
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        redrawWordsView(size)
        layoutTopView(size)

        wordsTableView.alpha = 0
        UIView.animate(withDuration: 0.6, delay: 0,
                options: [], animations: {
            self.wordsTableView.alpha = 1
        }, completion: nil)
    }

    func initView(_ messageToDecipher: Message) {
        message = messageToDecipher

        updateHintsCount()
        setTimer()
    }

    func giveUpPressed(_ sender: AnyObject) {
        if (message.getMessageStatus() != .ciphered) {
            return
        }

        WTFTwoButtonsAlert.show(GIVE_UP_TITLE_TEXT, message: "", firstButtonTitle: GIVE_UP_BUTTON_TEXT) { () -> Void in
            self.gameOver()
        }
    }

    fileprivate func redrawWordsView(_ size: CGSize? = nil) {
        let size = size ?? view.frame.size

        wordsTableView.updateMaxWidth(size.width - wordsViewHorizontalConstraint.constant * 2)
        wordsTableView.setNewMessage(message)
    }

    func setTimer() {
        if (message.guessIsNotStarted()) {
            timer.seconds = messageCipherService.getTimerSeconds(message)
        } else {
            timer.seconds = message.timerSecs
        }

        topTimerLabel.text = timer.getTimeString()
    }

    func layoutTopView(_ size: CGSize? = nil) {
        let size = size ?? view.frame.size

        if (size.width > size.height) {
            topPaddingConstraint.constant = 4
        } else {
            topPaddingConstraint.constant = initialTopPaddingConstraintConstant
        }
    }

    func updateMessage() {
        message.timerSecs = timer.seconds
        parentVC.sendMessageUpdate()
    }

    func start() {
        Timer.scheduledTimer(timeInterval: 1.0, target: self,
                selector: #selector(DecipherInProgressVC.tick), userInfo: nil, repeats: false)

        wordsTableView.setNewMessage(message)
        guessTextField.text = ""
        guessTextField.becomeFirstResponder()
        layoutTopView()
    }

    func tick() {
        if (message.getMessageStatus() != .ciphered) {
            return
        }

        if (isPaused) {
            Timer.scheduledTimer(timeInterval: 1.0, target: self,
                    selector: #selector(DecipherInProgressVC.tick), userInfo: nil, repeats: false)

            return
        }

        _ = timer.tick()

        topTimerLabel.text = timer.getTimeString()

        if (timer.isFinished()) {
            DispatchQueue.main.async(execute: {
                self.gameOver()
            })
        } else {
            Timer.scheduledTimer(timeInterval: 1.0, target: self,
                    selector: #selector(DecipherInProgressVC.tick), userInfo: nil, repeats: false)

            if (timer.isRunningOfTime()) {
                topTimerLabel.textColor = UIColor.red

                UIView.animate(withDuration: 0.5, delay: 0,
                        options: [.autoreverse, .repeat, .allowUserInteraction], animations: {
                    self.topTimerLabel.alpha = 0.1
                }, completion: nil)
            }
        }
    }

    func gameOver() {
        message.timerSecs = timer.seconds

        //stop timer animation if any
        topTimerLabel.layer.removeAllAnimations()
        topTimerLabel.alpha = 1
        topTimerLabel.textColor = UIColor.black

        dismissKeyboard()
        parentVC.gameOver()
    }

    func wtfsBought() {
        updateHintsCount()
        isPaused = false
        guessTextField.becomeFirstResponder()
    }
}
