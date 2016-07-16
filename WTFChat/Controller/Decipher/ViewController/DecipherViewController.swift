import Foundation

class DecipherViewController: BaseUIViewController, UITextFieldDelegate {
    let currentUserService: CurrentUserService = serviceLocator.get(CurrentUserService)
    let messageCipherService: MessageCipherService = serviceLocator.get(MessageCipherService)
    let audioService: AudioService = serviceLocator.get(AudioService)

    @IBOutlet weak var topTimerLabel: UILabel!
    @IBOutlet weak var topCategoryLabel: UILabel!
    @IBOutlet weak var topStopImage: UIImageView!

    @IBOutlet weak var resultLabel: RoundedLabel!

    @IBOutlet weak var startView: UIView!
    @IBOutlet weak var timerView: UIView!

    @IBOutlet weak var wordsTableView: WordsViewController!

    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var resultView: UIView!
    @IBOutlet weak var guessTextField: UITextField!
    @IBOutlet weak var tryButton: UIButton!

    @IBOutlet weak var bottomButtonsView: UIView!

    @IBOutlet weak var bottomViewConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomViewWordsPaddingContraint: NSLayoutConstraint!

    @IBOutlet weak var topPaddingConstraint: NSLayoutConstraint!

    @IBOutlet weak var resultViewHeightConstraint: NSLayoutConstraint!

    let SUCCESS_TEXT = "Success"
    let FAILED_TEXT = "Failed"

    var message: Message!
    var isStarted = false
    var isOvered = false
    var isPaused = false
    var timer = Timer()

    var hints = 0

    //for viewOnly mode
    var useCipherText = false
    var selfAuthor = false

    var initialViewFrame: CGRect!
    var expGainView = ExpGainView()

    var isInLandscapeMode = false
    var initialTopPaddingConstraintConstant: CGFloat = 0

    var resultViewHeightConstraintConstant: CGFloat = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        resultViewHeightConstraintConstant = resultViewHeightConstraint.constant
        initialTopPaddingConstraintConstant = topPaddingConstraint.constant

        let nav = self.navigationController?.navigationBar
        nav?.translucent = false

        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(DecipherViewController.keyboardWillShow(_:)), name:UIKeyboardWillShowNotification, object: nil);
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(DecipherViewController.keyboardWillHide(_:)), name:UIKeyboardWillHideNotification, object: nil);
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(DecipherViewController.rotated(_:)), name: UIDeviceOrientationDidChangeNotification, object: nil)

        let wordsTap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(DecipherViewController.viewTapped))
        wordsTableView.addGestureRecognizer(wordsTap)

        let giveUpTimerTap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(DecipherViewController.giveUpButtonPressed))
        topTimerLabel.addGestureRecognizer(giveUpTimerTap)

        let giveUpImageTap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(DecipherViewController.giveUpButtonPressed))
        topStopImage.addGestureRecognizer(giveUpImageTap)

        startView?.hidden = false
        bottomView.hidden = true
        topTimerLabel.hidden = true
        wordsTableView.hidden = true
        bottomButtonsView.hidden = true

        resultView.hidden = true
        resultViewHeightConstraint.constant = 0

        isStarted = false
        isOvered = false

        view.setNeedsLayout()
        view.layoutIfNeeded()

        if (view.frame.width > view.frame.height) {
            isInLandscapeMode = true
        } else {
            isInLandscapeMode = false
        }

        wordsTableView.hintComputer = self

        self.wordsTableView.delegate = self.wordsTableView
        self.wordsTableView.dataSource = self.wordsTableView
        self.wordsTableView.backgroundColor = UIColor.clearColor()

        guessTextField.delegate = self
        guessTextField.autocorrectionType = .No

        self.initialViewFrame = self.view.frame

        calcInitialHints()
        updateTimer()

        layoutTopView()
    }

    private func updateTimer() {
        if (message.guessIsNotStarted()) {
            timer.seconds = messageCipherService.getTimerSeconds(message)
        } else {
            timer.seconds = message.timerSecs
        }

        topTimerLabel.text = timer.getTimeString()
    }

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self);
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        isPaused = false
    }

    /*override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        if (UIDeviceOrientationIsLandscape(UIDevice.currentDevice().orientation)) {
            isInLandscapeMode = true
        } else if(UIDeviceOrientationIsPortrait(UIDevice.currentDevice().orientation)) {
            isInLandscapeMode = false
        }
    }*/

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)

        isPaused = true
    }

    @IBAction func viewTapped() {
        if (isOvered) {
            changeCipherStateForViewOnly()
        }
    }

    @IBAction func giveUpButtonPressed(sender: AnyObject) {
        if (isOvered) {
            return
        }

        WTFTwoButtonsAlert.show("Stop deciphering?",
            message: "",
            firstButtonTitle: "Give Up",
            secondButtonTitle: "Cancel",
            viewPresenter: self) { () -> Void in
            self.gameOver()
        }
    }

    //delegate enterPressed for guessField
    func textFieldShouldReturn(textField: UITextField) -> Bool {   //delegate method
        tryButtonPressed(tryButton)
        return true
    }

    func textFieldDidBeginEditing(textField: UITextField) {   //delegate method
        UIView.setAnimationsEnabled(false)
    }

    @IBAction func guessTextChanged(sender: AnyObject) {
        if (guessTextField.text?.characters.count > 0) {
            tryButton.enabled = true
        } else {
            tryButton.enabled = false
        }
    }

    @IBAction func tryButtonPressed(sender: AnyObject) {
        if (guessTextField.text!.characters.count > 1024) {
            WTFOneButtonAlert.show("Too many characters",
                message: "Your guess should be less than 1024 characters",
                firstButtonTitle: "Ok",
                viewPresenter: self)

            return
        }

        messageCipherService.decipher(message, guessText: guessTextField.text!)

        let guessWords = guessTextField.text!.characters.split {$0 == " "}.map { String($0) }

        wordsTableView.updateMessage(message, tries: guessWords)
        guessTextField.text = ""
        tryButton.enabled = false

        if (message.deciphered) {
            gameOver()
        } else {
            updateMessage()
        }
    }

    func keyboardWillShow(notification: NSNotification) {
        var info = notification.userInfo!
        let keyboardFrame: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()

        UIView.setAnimationsEnabled(true)

        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.bottomViewConstraint.constant = keyboardFrame.size.height
        })
    }

    func keyboardWillHide(notification: NSNotification) {
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.bottomViewConstraint.constant = 0
        })
    }

    func rotated(notification: NSNotification) {
        if (UIDeviceOrientationIsLandscape(UIDevice.currentDevice().orientation)) {
            if (!isInLandscapeMode) {
                isInLandscapeMode = true
                redrawWordsView()
                layoutTopView()
            }
        } else if(UIDeviceOrientationIsPortrait(UIDevice.currentDevice().orientation)) {
            if (isInLandscapeMode) {
                isInLandscapeMode = false
                redrawWordsView()
                layoutTopView()
            }
        }
    }

    func dismissKeyboard(){
        view.endEditing(true)
    }

    func changeCipherStateForViewOnly() {
        useCipherText = !useCipherText
        self.wordsTableView.setNewMessage(message, useCipherText: useCipherText, selfAuthor: selfAuthor)
    }

    private func redrawWordsView() {
        self.wordsTableView.updateMaxWidth()
        self.wordsTableView.setNewMessage(message, useCipherText: useCipherText, selfAuthor: selfAuthor)
    }

    private func layoutTopView() {
        if (isOvered) {
            return
        }

        if (isInLandscapeMode) {
            topPaddingConstraint.constant = 4
        } else {
            topPaddingConstraint.constant = initialTopPaddingConstraintConstant
        }
    }

    func hideTopLayer() {
        //TODO - add when needed
    }

    func setViewOnlyStage() {
        startView?.removeFromSuperview()
        wordsTableView.updateMessage(message)
        wordsTableView.hidden = false

        bottomViewHeightConstraint.constant = 0
        bottomButtonsView.hidden = false

        self.hideTopLayer()

        isStarted = true
        isOvered = true
    }

    func updateMessage() {
        if (isOvered) {
            return
        }

        //update timer
        message.timerSecs = timer.seconds

        sendMessageUpdate()
    }

    func sendMessageUpdate() {
        fatalError("This method must be overridden")
    }

    func sendMessageDecipher() {
        fatalError("This method must be overridden")
    }
}
