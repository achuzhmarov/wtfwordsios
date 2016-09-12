import Foundation
import Localize_Swift

class DecipherInProgressVC: UIViewController {
    let currentUserService: CurrentUserService = serviceLocator.get(CurrentUserService)
    let messageCipherService: MessageCipherService = serviceLocator.get(MessageCipherService)
    let audioService: AudioService = serviceLocator.get(AudioService)

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

    private let GIVE_UP_TITLE_TEXT = "Stop deciphering?".localized()
    private let GIVE_UP_BUTTON_TEXT = "Give Up".localized()
    private let TRY_TEXT = "Try".localized()
    private let GUESS_PLACEHOLDER_TEXT = "Enter your guess here".localized()

    var message: Message!

    var isPaused = false
    var timer = Timer()

    var hints = 0

    var initialTopPaddingConstraintConstant: CGFloat = 0

    var parent: DecipherViewController {
        return parentViewController as! DecipherViewController
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.clearColor()

        initialTopPaddingConstraintConstant = topPaddingConstraint.constant

        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(DecipherInProgressVC.keyboardWillShow(_:)), name:UIKeyboardWillShowNotification, object: nil);
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(DecipherInProgressVC.keyboardWillHide(_:)), name:UIKeyboardWillHideNotification, object: nil);

        let giveUpTap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(DecipherInProgressVC.giveUpPressed))
        topTimerLabel.addGestureRecognizer(giveUpTap)
        topStopImage.addGestureRecognizer(giveUpTap)
        topGiveUpView.addGestureRecognizer(giveUpTap)

        wordsTableView.hintComputer = self
        wordsTableView.delegate = wordsTableView
        wordsTableView.dataSource = wordsTableView
        wordsTableView.backgroundColor = UIColor.clearColor()

        guessTextField.delegate = self
        guessTextField.autocorrectionType = .No

        layoutTopView()

        tryButton.setTitle(TRY_TEXT, forState: .Normal)

        let placeholder = NSAttributedString(string: GUESS_PLACEHOLDER_TEXT, attributes: [NSForegroundColorAttributeName : UIColor.lightGrayColor()])
        guessTextField.attributedPlaceholder = placeholder
    }

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self);
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        isPaused = false
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)

        isPaused = true
    }

    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)

        redrawWordsView(size)
        layoutTopView(size)

        wordsTableView.alpha = 0
        UIView.animateWithDuration(0.6, delay: 0,
                options: [], animations: {
            self.wordsTableView.alpha = 1
        }, completion: nil)
    }

    func initView(messageToDecipher: Message) {
        message = messageToDecipher

        updateHintsCount()
        setTimer()
    }

    func giveUpPressed(sender: AnyObject) {
        if (message.getMessageStatus() != .Ciphered) {
            return
        }

        WTFTwoButtonsAlert.show(GIVE_UP_TITLE_TEXT, message: "", firstButtonTitle: GIVE_UP_BUTTON_TEXT) { () -> Void in
            self.gameOver()
        }
    }

    private func redrawWordsView(size: CGSize? = nil) {
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

    func layoutTopView(size: CGSize? = nil) {
        let size = size ?? view.frame.size

        if (size.width > size.height) {
            topPaddingConstraint.constant = 4
        } else {
            topPaddingConstraint.constant = initialTopPaddingConstraintConstant
        }
    }

    func updateMessage() {
        message.timerSecs = timer.seconds
        parent.sendMessageUpdate()
    }

    func start() {
        NSTimer.scheduledTimerWithTimeInterval(1.0, target: self,
                selector: #selector(DecipherInProgressVC.tick), userInfo: nil, repeats: false)

        wordsTableView.setNewMessage(message)
        guessTextField.text = ""
        guessTextField.becomeFirstResponder()
        layoutTopView()
    }

    func tick() {
        if (message.getMessageStatus() != .Ciphered) {
            return
        }

        if (isPaused) {
            NSTimer.scheduledTimerWithTimeInterval(1.0, target: self,
                    selector: #selector(DecipherInProgressVC.tick), userInfo: nil, repeats: false)

            return
        }

        timer.tick()

        topTimerLabel.text = timer.getTimeString()

        if (timer.isFinished()) {
            dispatch_async(dispatch_get_main_queue(), {
                self.gameOver()
            })
        } else {
            NSTimer.scheduledTimerWithTimeInterval(1.0, target: self,
                    selector: #selector(DecipherInProgressVC.tick), userInfo: nil, repeats: false)

            if (timer.isRunningOfTime()) {
                topTimerLabel.textColor = UIColor.redColor()

                UIView.animateWithDuration(0.5, delay: 0,
                        options: [.Autoreverse, .Repeat, .AllowUserInteraction], animations: {
                    self.topTimerLabel.alpha = 0.1
                }, completion: nil)
            } else if (timer.isLastSecond()) {
                topTimerLabel.layer.removeAllAnimations()
                topTimerLabel.alpha = 1
            }
        }
    }

    func gameOver() {
        message.timerSecs = timer.seconds
        dismissKeyboard()
        parent.gameOver()
    }

    func hintsBought() {
        updateHintsCount()
        isPaused = false
        guessTextField.becomeFirstResponder()
    }
}
