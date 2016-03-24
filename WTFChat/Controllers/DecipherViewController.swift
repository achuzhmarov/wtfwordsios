//
//  DecipherViewController.swift
//  WTFChat
//
//  Created by Artem Chuzhmarov on 07/09/15.
//  Copyright (c) 2015 Artem Chuzhmarov. All rights reserved.
//

import UIKit

class DecipherViewController: UIViewController, SuggestionComputer, UITextFieldDelegate {
    @IBOutlet weak var topTimerLabel: UILabel!
    
    @IBOutlet weak var startLabel: UILabel!
    @IBOutlet weak var topView: UIView!
    
    @IBOutlet weak var wordsTableView: WordsViewController!
    
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var guessTextField: UITextField!
    @IBOutlet weak var tryButton: UIButton!
    
    @IBOutlet weak var bottomViewConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var topViewHeightContraint: NSLayoutConstraint!
    
    var talk: Talk!
    var message: Message!
    var isStarted = false
    var isOvered = false
    var isPaused = false
    var timer = Timer()
    
    var isSingleMode = false
    var suggestions = 0
    
    //for viewOnly mode
    var useCipherText = false
    var selfAuthor = false
    
    let SECONDS_PER_WORD = 20
    let HARD_SECONDS_PER_WORD = 30
    let SUGGESTIONS_SINGLE_MODE = 5
    
    var initialViewFrame: CGRect!
    var expGainView = ExpGainView()
    
    var isInLandscapeMode = false
    var initialTopViewHeightConstraintConstant = CGFloat(0)
    
    let viewTitle = "Decipher"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initialTopViewHeightConstraintConstant = topViewHeightContraint.constant
        
        let nav = self.navigationController?.navigationBar
        nav?.translucent = false
        
        self.title = viewTitle
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(DecipherViewController.keyboardWillShow(_:)), name:UIKeyboardWillShowNotification, object: nil);
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(DecipherViewController.keyboardWillHide(_:)), name:UIKeyboardWillHideNotification, object: nil);
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(DecipherViewController.rotated(_:)), name: UIDeviceOrientationDidChangeNotification, object: nil)
        
        //Looks for single or multiple taps.
        let tapDismiss: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(DecipherViewController.dismissKeyboard))
        let tapStart: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(DecipherViewController.viewTapped))
        view.addGestureRecognizer(tapDismiss)
        view.addGestureRecognizer(tapStart)
        
        startLabel.hidden = false
        bottomView.hidden = true
        topTimerLabel.hidden = true
        wordsTableView.hidden = true
        isStarted = false
        isOvered = false
        
        view.setNeedsLayout()
        view.layoutIfNeeded()
        
        wordsTableView.suggestionComputer = self
        
        if (message.deciphered || selfAuthor) {
            setViewOnlyStage()
        } else {
            UIView.animateWithDuration(1, delay: 0,
                options: [.Repeat, .Autoreverse], animations: {
                    self.startLabel.alpha = 0
                }, completion: nil)
        }
        
        if (self.isSingleMode) {
            suggestions = (message.countNew() - 1) / SUGGESTIONS_SINGLE_MODE + 1
        } else {
            suggestions = currentUserService.getUserSuggestions() - message.hintsUsed
        }
        
        self.wordsTableView.delegate = self.wordsTableView
        self.wordsTableView.dataSource = self.wordsTableView
        
        guessTextField.delegate = self
        
        self.initialViewFrame = self.view.frame
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self);
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        isPaused = false
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if (UIDeviceOrientationIsLandscape(UIDevice.currentDevice().orientation)) {
            isInLandscapeMode = true
        } else if(UIDeviceOrientationIsPortrait(UIDevice.currentDevice().orientation)) {
            isInLandscapeMode = false
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        isPaused = true
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
        
        messageCipher.decipher(message!, guessText: guessTextField.text!)
        
        let guessWords = guessTextField.text!.characters.split {$0 == " "}.map { String($0) }
        
        wordsTableView.updateMessage(message!, tries: guessWords)
        guessTextField.text = ""
        tryButton.enabled = false
        
        if (message!.deciphered) {
            gameOver()
        } else {
            sendMessageUpdate()
        }
    }
    
    func suggestionTapped(word: Word) {
        if (isOvered) {
            changeCipherStateForViewOnly()
            return
        }
        
        if (word.wordType == WordType.New) {
            if (word.wasCloseTry) {
                showCloseTrySuggestionsConfirm(word)
            } else if (suggestions > 0) {
                showSuggestionConfirm(word)
            } else {
                showNoSuggestionsDialog()
            }
        } else {
            //do nothing
        }
    }
    
    func showNoSuggestionsDialog() {
        if (isSingleMode) {
            WTFOneButtonAlert.show("Hints remained: 0",
                message: "You have used all hints",
                firstButtonTitle: "Ok",
                viewPresenter: self)
        } else {
            WTFTwoButtonsAlert.show("Hints remained: 0",
                message: "You have used all hints. Want to get more?",
                firstButtonTitle: "Get more",
                secondButtonTitle: "Cancel",
                viewPresenter: self) { () -> Void in
                    
                    self.performSegueWithIdentifier("getMoreHints", sender: self)
            }
        }
    }
    
    func showSuggestionConfirm(word: Word) {
        WTFTwoButtonsAlert.show("Hints remained: \(String(suggestions))",
            message: "",
            firstButtonTitle: "Use a Hint",
            secondButtonTitle: "Cancel",
            viewPresenter: self) { () -> Void in
                self.useSuggestion(word)
        }
    }
    
    func showCloseTrySuggestionsConfirm(word: Word) {
        WTFTwoButtonsAlert.show("Open this word?",
            message: "",
            firstButtonTitle: "Open",
            secondButtonTitle: "Cancel",
            viewPresenter: self) { () -> Void in
                self.useSuggestion(word)
        }
    }
    
    func useSuggestion(word: Word) {
        if (isOvered) {
            return
        }
        
        audioHelper.playSound("success")
        
        if (word.wasCloseTry) {
            messageCipher.decipher(message!, suggestedWord: word, closeTry: true)
        } else {
            messageCipher.decipher(message!, suggestedWord: word)
            suggestions -= 1
            
            if (!isSingleMode) {
                message.hintsUsed += 1
                suggestions = currentUserService.getUserSuggestions() - message.hintsUsed
            }
        }
        
        wordsTableView.updateMessage(message!)
        
        if (message!.deciphered) {
            gameOver()
        } else {
            sendMessageUpdate()
        }
    }
    
    func keyboardWillShow(notification: NSNotification) {
        var info = notification.userInfo!
        let keyboardFrame: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        
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
                redrawWordsView()
                
                if (!isOvered) {
                    hideTopTimer()
                }
            }
            
            isInLandscapeMode = true
            
        } else if(UIDeviceOrientationIsPortrait(UIDevice.currentDevice().orientation)) {
            
            if (isInLandscapeMode) {
                redrawWordsView()
                
                if (!isOvered) {
                    showTopTimer()
                }
            }
            
            isInLandscapeMode = false
            
        }
    }
    
    private func redrawWordsView() {
        self.wordsTableView.updateMaxWidth()
        self.wordsTableView.setNewMessage(message, useCipherText: useCipherText, selfAuthor: selfAuthor)
    }
    
    private func hideTopTimer() {
        topViewHeightContraint.constant = 0
        topTimerLabel.text = ""
        self.title = timer.getTimeString()
    }
    
    private func showTopTimer() {
        topViewHeightContraint.constant = initialTopViewHeightConstraintConstant
        topTimerLabel.text = timer.getTimeString()
        self.title = viewTitle
    }
    
    func dismissKeyboard(){
        view.endEditing(true)
    }
    
    func changeCipherStateForViewOnly() {
        useCipherText = !useCipherText
        self.wordsTableView.setNewMessage(message, useCipherText: useCipherText, selfAuthor: selfAuthor)
    }
    
    func viewTapped() {
        if (isOvered) {
            changeCipherStateForViewOnly()
        } else if (!isStarted) {
            start()
        }
    }
    
    func start() {
        self.navigationItem.setHidesBackButton(true, animated:true)

        if (message!.timerSecs == 0 && message!.countSuccess() == 0) {
            let (_, mode) = CipherFactory.getCategoryAndMode(message!.cipherType)
            
            if (mode == CipherMode.Hard) {
                timer.seconds = message!.countNew() * HARD_SECONDS_PER_WORD
            } else {
                timer.seconds = message!.countNew() * SECONDS_PER_WORD
            }
        } else {
            timer.seconds = message!.timerSecs
        }
        
        if (isInLandscapeMode) {
            hideTopTimer()
        } else {
            showTopTimer()
        }
        
        NSTimer.scheduledTimerWithTimeInterval(1.0, target: self,
            selector: #selector(DecipherViewController.tick), userInfo: nil, repeats: false)
        
        bottomView.hidden = false
        topTimerLabel.hidden = false
        wordsTableView.hidden = false
        
        startLabel.removeFromSuperview()
        
        wordsTableView.updateMessage(message!)
        
        guessTextField.becomeFirstResponder()

        let giveUpButton = UIBarButtonItem(title: "Give Up", style: .Plain, target: self, action: #selector(DecipherViewController.giveUpButtonPressed(_:)))
        navigationItem.rightBarButtonItem = giveUpButton
        
        isStarted = true
    }
    
    func gameOver() {
        if (!talk.isSingleMode) {
            talk.cipheredNum -= 1
        }
        
        messageCipher.failed(message!)
        message.timerSecs = timer.seconds
        
        bottomView.hidden = true
        bottomViewHeightConstraint.constant = 0

        wordsTableView.updateMessage(message!)
        
        dismissKeyboard()
        
        if (message!.countFailed() == 0) {
            audioHelper.playSound("win")
        } else {
            audioHelper.playSound("lose")
        }
        
        self.navigationItem.setHidesBackButton(false, animated:true)
        self.title = viewTitle
        
        isOvered = true
        
        if (message.countSuccess() > 0 && !isSingleMode) {
            timer.seconds = 0
            topTimerLabel.text = ""
            topViewHeightContraint.constant = initialTopViewHeightConstraintConstant
            self.expGainView.myInit(self.topView)
        } else {
            self.hideTopLayer()
        }
        
        sendMessageDecipher()
        
        navigationItem.rightBarButtonItem = nil
        
        messageService.updateMessageInTalk(message)
    }
    
    func hideTopLayer() {
        timer.seconds = 0
        topTimerLabel.text = ""
        
        topViewHeightContraint.constant = 0
        
        self.view.setNeedsLayout()
        self.view.layoutIfNeeded()
    }
    
    func setViewOnlyStage() {
        startLabel.removeFromSuperview()
        wordsTableView.updateMessage(message!)
        wordsTableView.hidden = false
        
        bottomViewHeightConstraint.constant = 0
        
        self.hideTopLayer()
        
        isStarted = true
        isOvered = true
    }
    
    func tick() {
        if (isOvered) {
            return
        }
        
        if (isPaused) {
            NSTimer.scheduledTimerWithTimeInterval(1.0, target: self,
                selector: #selector(DecipherViewController.tick), userInfo: nil, repeats: false)
            
            return
        }
        
        timer.tick()
        
        if (isInLandscapeMode) {
            self.title = timer.getTimeString()
        } else {
            topTimerLabel.text = timer.getTimeString()
        }
        
        if (timer.isFinished()) {
            dispatch_async(dispatch_get_main_queue(), {
                self.gameOver()
            })
        } else {
            NSTimer.scheduledTimerWithTimeInterval(1.0, target: self,
                selector: #selector(DecipherViewController.tick), userInfo: nil, repeats: false)
            
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
    
    func sendMessageUpdate() {
        if (isOvered) {
            //do nothing
            return
        }
        
        //update timer
        message.timerSecs = timer.seconds
        
        if (isSingleMode) {
            CoreMessage.updateMessage(message)
        } else {
            messageService.decipherMessage(message) { (message, error) -> Void in
                if let requestError = error {
                    print(requestError)
                }
            }
        }
    }
    
    func sendMessageDecipher() {
        if (isSingleMode) {
            CoreMessage.updateMessage(message)
        } else {
            messageService.decipherMessage(message) { (message, error) -> Void in
                dispatch_async(dispatch_get_main_queue(), {
                    if let requestError = error {
                        //TODO - show error to user
                        print(requestError)
                    } else {
                        if (message!.exp > 0) {
                            self.expGainView.runProgress(message!.exp)
                        }
                    }
                })
            }
        }

    }
    
    @IBAction func hintsBought(segue:UIStoryboardSegue) {
        suggestions = currentUserService.getUserSuggestions() - message.hintsUsed
    }
}
