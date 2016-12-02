import Foundation
import Localize_Swift

class DecipherInProgressByLettersVC: UIViewController {
    let currentUserService: CurrentUserService = serviceLocator.get(CurrentUserService.self)
    let messageCipherService: MessageCipherService = serviceLocator.get(MessageCipherService.self)
    let audioService: AudioService = serviceLocator.get(AudioService.self)

    @IBOutlet weak var topTimerLabel: UILabel!
    @IBOutlet weak var topCategoryLabel: UILabel!
    @IBOutlet weak var topStopImage: UIImageView!
    @IBOutlet weak var topGiveUpView: UIView!

    @IBOutlet weak var wordsTableView: WordsViewController!
    @IBOutlet weak var decipherView: UIView!

    @IBOutlet weak var topPaddingConstraint: NSLayoutConstraint!
    @IBOutlet weak var wordsViewHorizontalConstraint: NSLayoutConstraint!

    var controller: GameController!

    private let GIVE_UP_TITLE_TEXT = "Stop deciphering?".localized()
    private let GIVE_UP_BUTTON_TEXT = "Give Up".localized()

    var message: Message!

    var isPaused = false
    var timer = WTFTimer()

    var initialTopPaddingConstraintConstant: CGFloat = 0

    var parentVC: DecipherViewController {
        return parent as! DecipherViewController
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.clear

        initialTopPaddingConstraintConstant = topPaddingConstraint.constant

        let giveUpTap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.giveUpPressed))
        topTimerLabel.addGestureRecognizer(giveUpTap)
        topStopImage.addGestureRecognizer(giveUpTap)
        topGiveUpView.addGestureRecognizer(giveUpTap)

        wordsTableView.wordTappedComputer = self
        wordsTableView.delegate = wordsTableView
        wordsTableView.dataSource = wordsTableView
        wordsTableView.backgroundColor = UIColor.clear

        layoutTopView()

        view.setNeedsLayout()
        view.layoutIfNeeded()

        initGameController()

        let decipherWidth = decipherView.bounds.size.width
        let decipherHeight = decipherView.bounds.size.height

        //add one layer for all game elements
        let gameView = UIView(frame: CGRect(x: 0, y: 0, width: decipherWidth, height: decipherHeight))
        decipherView.addSubview(gameView)
        controller.gameView = gameView

        let hudView = HUDView(frame: CGRect(x: 0, y: 0, width: decipherWidth, height: decipherHeight))
        decipherView.addSubview(hudView)
        controller.hudView = hudView

        //set parent functions to use
        controller.onWordSolved = self.wordSolved
        controller.getMoreWtf = self.getMoreWtf
        controller.useWtf = self.useWtf
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

    func initGameController() {
        controller = GameController()
    }

    func initView(_ messageToDecipher: Message) {
        message = messageToDecipher

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
        wordsTableView.setNewMessage(message)
        layoutTopView()
        controller.clearCache()
        controller.cipherType = message.cipherType
        controller.cipherDifficulty = message.cipherDifficulty
        showNextWord()

        initTimerForOneSecond()
    }

    private func initTimerForOneSecond() {
        let secondTimer = Timer.scheduledTimer(timeInterval: 1.0,
                target: self,
                selector: #selector(self.tick),
                userInfo: nil,
                repeats: false)

        RunLoop.main.add(secondTimer, forMode: RunLoopMode.commonModes)
    }

    func tick() {
        if (message.getMessageStatus() != .ciphered) {
            return
        }

        if (isPaused) {
            initTimerForOneSecond()

            return
        }

        _ = timer.tick()

        topTimerLabel.text = timer.getTimeString()

        if (timer.isFinished()) {
            DispatchQueue.main.async(execute: {
                self.gameOver()
            })
        } else {
            initTimerForOneSecond()

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

        parentVC.gameOver()
    }

    func wtfBought() {
        isPaused = false
    }

    func wordSolved(solvedWord: Word) {
        if (message.getMessageStatus() != .ciphered) {
            return
        }

        audioService.playSound("success")

        messageCipherService.decipher(message, hintedWord: solvedWord)
        wordsTableView.updateMessage(message, hideError: true)

        if (message.deciphered) {
            gameOver()
        } else {
            updateMessage()
            showNextWord(solvedWord)
        }
    }

    private func showNextWord(_ solvedWord: Word) {
        var wasFind = false

        for word: Word in message.words {
            if (wasFind) && ((word.type == .new) || (word.type == .closeTry)) {
                controller.setNewWord(word)
                wordsTableView.highlightWord(word)
                controller.start()
                return
            }

            if (word == solvedWord) {
                wasFind = true
            }
        }

        showNextWord()
    }

    private func showNextWord() {
        for word: Word in message.words {
            if (word.type == .new) || (word.type == .closeTry) {
                controller.setNewWord(word)
                wordsTableView.highlightWord(word)
                controller.start()
                return
            }
        }
    }

    func wasShaked() {
        controller.clearPlacedTiles()
    }

    func getMoreWtf() {
        self.isPaused = true
        self.performSegue(withIdentifier: "getMoreWtf", sender: self)
    }

    func useWtf(_ wtf: Int) {
        message.wtfUsed += wtf
        currentUserService.useWtf(wtf)
    }
}

extension DecipherInProgressByLettersVC: WordTappedComputer {
    func wordTapped(_ word: Word) {
        if (word.type == .new) || (word.type == .closeTry) {
            controller.setNewWord(word)
            controller.start()
        } else {
            //ignore tap
        }
    }
}