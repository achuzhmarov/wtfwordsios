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
    @IBOutlet weak var wordsView: WordsView!
    @IBOutlet weak var guessTextField: UITextField!
    @IBOutlet weak var tryButton: UIButton!
    
    @IBOutlet weak var guessBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var tryBottomConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var topViewHeightContraint: NSLayoutConstraint!
    
    var message: Message!
    var isStarted = false
    var isOvered = false
    var timer = Timer()
    
    var isSingleMode = false
    var suggestionsForSingleMode = 0
    
    let secondsPerWord = 20
    let suggestionsToWordsForSingleMode = 3
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let nav = self.navigationController?.navigationBar
        nav?.translucent = false

        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow:"), name:UIKeyboardWillShowNotification, object: nil);
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillHide:"), name:UIKeyboardWillHideNotification, object: nil);
        /*NSNotificationCenter.defaultCenter().addObserver(self, selector: "rotated:", name: UIDeviceOrientationDidChangeNotification, object: nil)*/
        
        //Looks for single or multiple taps.
        let tapDismiss: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        let tapStart: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "start")
        view.addGestureRecognizer(tapDismiss)
        view.addGestureRecognizer(tapStart)
        
        self.view.setNeedsLayout()
        self.view.layoutIfNeeded()
        
        if (message.deciphered) {
            setViewOnlyStage()
        } else {
            UIView.animateWithDuration(1, delay: 0,
                options: [.Repeat, .Autoreverse], animations: {
                    self.startLabel.alpha = 0
                }, completion: nil)
        }
        
        if (self.isSingleMode) {
            suggestionsForSingleMode = (message.countNew() - 1) / suggestionsToWordsForSingleMode + 1
        }
        
        self.wordsView.setNeedsLayout()
        self.wordsView.layoutIfNeeded()
        
        guessTextField.delegate = self
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self);
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func giveUpButtonPressed(sender: AnyObject) {
        if (isOvered) {
            return
        }
        
        let refreshAlert = UIAlertController(title: "Give Up", message: "Are you sure you want to give up?", preferredStyle: UIAlertControllerStyle.Alert)
        
        refreshAlert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: { (action: UIAlertAction) in
            self.gameOver()
        }))
        
        refreshAlert.addAction(UIAlertAction(title: "Cancel", style: .Default, handler: { (action: UIAlertAction) in
            //do nothing
        }))
        
        presentViewController(refreshAlert, animated: true, completion: nil)
    }
    
    //delegate enterPressed for guessField
    func textFieldShouldReturn(textField: UITextField) -> Bool {   //delegate method
        tryButtonPressed(tryButton)
        return true
    }
    
    @IBAction func tryButtonPressed(sender: AnyObject) {
        messageCipher.decipher(message!, guessText: guessTextField.text!)
        
        let guessWords = guessTextField.text!.characters.split {$0 == " "}.map { String($0) }
        
        wordsView.updateMessage(message!, tries: guessWords)
        guessTextField.text = ""
        
        if (message!.deciphered) {
            gameOver()
        }
    }
    
    func suggestionTapped(word: Word) {
        if (word.wordType == WordType.New) {
            if (self.getSuggestions() > 0) {
                showSuggestionConfirm(word)
            } else {
                showNoSuggestionsDialog()
            }
        } else {
            //do nothing
        }
    }
    
    func showNoSuggestionsDialog() {
        let refreshAlert = UIAlertController(title: "Use Suggestion: 0",
            message: "You have used all suggestions",
            preferredStyle: UIAlertControllerStyle.Alert)
        
        refreshAlert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: { (action: UIAlertAction) in
            //do nothing
        }))
        
        presentViewController(refreshAlert, animated: true, completion: nil)
    }
    
    func showSuggestionConfirm(word: Word) {
        let refreshAlert = UIAlertController(title: "Use Suggestion: " + String(self.getSuggestions()),
            message: "Are you sure you want to use a suggestion?",
            preferredStyle: UIAlertControllerStyle.Alert)
        
        refreshAlert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: { (action: UIAlertAction) in
            self.useSuggestion(word)
        }))
        
        refreshAlert.addAction(UIAlertAction(title: "Cancel", style: .Default, handler: { (action: UIAlertAction) in
            //do nothing
        }))
        
        presentViewController(refreshAlert, animated: true, completion: nil)
    }
    
    func useSuggestion(word: Word) {
        audioHelper.playSound("success")
        
        messageCipher.decipher(message!, suggestedWord: word)
        wordsView.updateMessage(message!)
        
        if (isSingleMode) {
            self.suggestionsForSingleMode--
        } else {
            userService.useSuggestion()
        }
        
        if (message!.deciphered) {
            gameOver()
        }
    }
    
    func keyboardWillShow(notification: NSNotification) {
        var info = notification.userInfo!
        let keyboardFrame: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.guessBottomConstraint.constant = keyboardFrame.size.height + 20
            self.tryBottomConstraint.constant = keyboardFrame.size.height + 20
        })
    }
    
    func keyboardWillHide(notification: NSNotification) {
        //var info = notification.userInfo!
        //var keyboardFrame: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.guessBottomConstraint.constant = 8
            self.tryBottomConstraint.constant = 8
        })
    }
    
    /*func rotated() {
        println("asdA")
    }*/
    
    func dismissKeyboard(){
        view.endEditing(true)
    }

    func start() {
        if (isStarted) {
            return
        }
        
        self.navigationItem.setHidesBackButton(true, animated:true)
        
        timer.seconds = message!.countNew() * secondsPerWord
        topTimerLabel.text = timer.getTimeString()
        
        NSTimer.scheduledTimerWithTimeInterval(1.0, target: self,
            selector: "tick", userInfo: nil, repeats: false)

        tryButton.hidden = false
        guessTextField.hidden = false
        topTimerLabel.hidden = false
        
        startLabel.removeFromSuperview()
        
        wordsView.suggestionComputer = self
        wordsView.updateMessage(message!)
        
        guessTextField.becomeFirstResponder()
        
        isStarted = true
    }
    
    func gameOver() {
        messageCipher.failed(message!)
        
        guessTextField.hidden = true
        guessTextField.text = ""
        tryButton.hidden = true
        
        wordsView.updateMessage(message!)
        
        dismissKeyboard()
        
        if (message!.countFailed() == 0) {
            audioHelper.playSound("win")
        } else {
            audioHelper.playSound("lose")
        }
        
        self.navigationItem.setHidesBackButton(false, animated:true)
        self.hideTopTimer()
        
        isOvered = true
        
        if (!isSingleMode) {
            messageService.decipherMessage(message) { (message, error) -> Void in
                dispatch_async(dispatch_get_main_queue(), {
                    if let requestError = error {
                        //TODO - show error to user
                        print(requestError)
                    } else {
                        //OK - do nothing
                    }
                })
            }
            
            userService.sendUsedSugegstions()
        }
    }
    
    func hideTopTimer() {
        timer.seconds = 0
        topTimerLabel.text = ""
        
        topViewHeightContraint.constant = 0
        self.view.setNeedsLayout()
        self.view.layoutIfNeeded()
    }
    
    func setViewOnlyStage() {
        startLabel.removeFromSuperview()
        wordsView.updateMessage(message!)
        
        self.hideTopTimer()
        
        isStarted = true
        isOvered = true
    }
    
    func tick() {
        if (isOvered) {
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
                selector: "tick", userInfo: nil, repeats: false)
            
            if (timer.isRunningOfTime()) {
                topTimerLabel.textColor = UIColor.redColor()

                UIView.animateWithDuration(0.5, delay: 0,
                    options: [.Autoreverse, .Repeat], animations: {
                        self.topTimerLabel.alpha = 0.1
                    }, completion: nil)
            } else if (timer.isLastSecond()) {
                topTimerLabel.layer.removeAllAnimations()
                topTimerLabel.alpha = 1
            }
        }
    }
    
    func getSuggestions() -> Int {
        if (isSingleMode) {
            return suggestionsForSingleMode
        } else {
            return userService.currentUser!.suggestions
        }
    }
    
    /*override func shouldAutorotate() -> Bool {
        return false
    }
    
    override func supportedInterfaceOrientations() -> Int {
        return UIInterfaceOrientation.Portrait.rawValue
    }*/
}
