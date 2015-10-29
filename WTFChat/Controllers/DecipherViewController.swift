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
    
    @IBOutlet weak var topViewHeightContraint: NSLayoutConstraint!
    
    var talk: Talk!
    var message: Message!
    var isStarted = false
    var isOvered = false
    var timer = Timer()
    
    var isSingleMode = false
    var suggestionsForSingleMode = 0
    
    //for viewOnly mode
    var useCipherText = false
    var selfAuthor = false
    
    let SECONDS_PER_WORD = 20
    let HARD_SECONDS_PER_WORD = 30
    let SUGGESTIONS_SINGLE_MODE = 3
    
    var initialViewFrame: CGRect!
    var isExpViewShown = false
    var expView: UIView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let nav = self.navigationController?.navigationBar
        nav?.translucent = false
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow:"), name:UIKeyboardWillShowNotification, object: nil);
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillHide:"), name:UIKeyboardWillHideNotification, object: nil);
        /*NSNotificationCenter.defaultCenter().addObserver(self, selector: "rotated:", name: UIDeviceOrientationDidChangeNotification, object: nil)*/
        
        //Looks for single or multiple taps.
        let tapDismiss: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        let tapStart: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "viewTapped")
        view.addGestureRecognizer(tapDismiss)
        view.addGestureRecognizer(tapStart)
        
        self.view.setNeedsLayout()
        self.view.layoutIfNeeded()
        
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
            suggestionsForSingleMode = (message.countNew() - 1) / SUGGESTIONS_SINGLE_MODE + 1
        }
        
        self.wordsTableView.delegate = self.wordsTableView
        self.wordsTableView.dataSource = self.wordsTableView
        
        guessTextField.delegate = self
        
        self.initialViewFrame = self.view.frame
    }
    
    //TODO - for testing
    /*override func viewDidAppear(animated: Bool) {
        showExpGain(100)
    }*/
    
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
        
        WTFTwoButtonsAlert.show("Give Up",
            message: "Are you sure you want to give up?",
            firstButtonTitle: "Ok",
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
        messageCipher.decipher(message!, guessText: guessTextField.text!)
        
        let guessWords = guessTextField.text!.characters.split {$0 == " "}.map { String($0) }
        
        wordsTableView.updateMessage(message!, tries: guessWords)
        guessTextField.text = ""
        tryButton.enabled = false
        
        if (message!.deciphered) {
            gameOver()
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
            } else if (self.getSuggestions() > 0) {
                showSuggestionConfirm(word)
            } else {
                showNoSuggestionsDialog()
            }
        } else {
            //do nothing
        }
    }
    
    func showNoSuggestionsDialog() {
        WTFOneButtonAlert.show("Use Hint: 0",
            message: "You have used all hints",
            firstButtonTitle: "Ok",
            viewPresenter: self)
    }
    
    func showSuggestionConfirm(word: Word) {
        WTFTwoButtonsAlert.show("Use Hint: " + String(self.getSuggestions()),
            message: "Are you sure you want to use a hint?",
            firstButtonTitle: "Ok",
            secondButtonTitle: "Cancel",
            viewPresenter: self) { () -> Void in
                self.useSuggestion(word)
        }
    }
    
    func showCloseTrySuggestionsConfirm(word: Word) {
        WTFTwoButtonsAlert.show("Descipher",
            message: "Are you sure you want to decipher it?",
            firstButtonTitle: "Ok",
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
        
        messageCipher.decipher(message!, suggestedWord: word)
        wordsTableView.updateMessage(message!)
        
        if (word.wasCloseTry) {
            //do nothing
        } else if (isSingleMode) {
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
            self.bottomViewConstraint.constant = keyboardFrame.size.height
        })
    }
    
    func keyboardWillHide(notification: NSNotification) {
        //var info = notification.userInfo!
        //var keyboardFrame: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.bottomViewConstraint.constant = 0
        })
    }
    
    /*func rotated() {
    println("asdA")
    }*/
    
    func dismissKeyboard(){
        view.endEditing(true)
    }
    
    func changeCipherStateForViewOnly() {
        useCipherText = !useCipherText
        self.wordsTableView.setNewMessage(message, useCipherText: useCipherText, selfAuthor: selfAuthor)
    }
    
    func viewTapped() {
        if (isExpViewShown) {
            removeExpView()
        } else if (isOvered) {
            changeCipherStateForViewOnly()
        } else if (!isStarted) {
            start()
        }
    }
    
    func start() {
        self.navigationItem.setHidesBackButton(true, animated:true)

        let (_, mode) = CipherFactory.getCategoryAndMode(message!.cipherType)
        
        if (mode == CipherMode.Hard) {
            timer.seconds = message!.countNew() * HARD_SECONDS_PER_WORD
        } else {
            timer.seconds = message!.countNew() * SECONDS_PER_WORD
        }
        
        topTimerLabel.text = timer.getTimeString()
        
        NSTimer.scheduledTimerWithTimeInterval(1.0, target: self,
            selector: "tick", userInfo: nil, repeats: false)
        
        //tryButton.hidden = false
        //guessTextField.hidden = false
        bottomView.hidden = false
        topTimerLabel.hidden = false
        wordsTableView.hidden = false
        
        startLabel.removeFromSuperview()
        
        wordsTableView.updateMessage(message!)
        
        guessTextField.becomeFirstResponder()

        isStarted = true
    }
    
    func gameOver() {
        if (!talk.isSingleMode) {
            talk.cipheredNum--
        }
        
        messageCipher.failed(message!)
        
        bottomView.hidden = true
        //guessTextField.hidden = true
        //guessTextField.text = ""
        //tryButton.hidden = true
        self.hideTopLayer()
        
        wordsTableView.updateMessage(message!)
        
        dismissKeyboard()
        
        if (message!.countFailed() == 0) {
            audioHelper.playSound("win")
        } else {
            audioHelper.playSound("lose")
        }
        
        self.navigationItem.setHidesBackButton(false, animated:true)
        
        isOvered = true
        
        if (!isSingleMode) {
            messageService.decipherMessage(message) { (message, error) -> Void in
                dispatch_async(dispatch_get_main_queue(), {
                    if let requestError = error {
                        //TODO - show error to user
                        print(requestError)
                    } else {
                        self.showExpGain(message!.exp)
                    }
                })
            }
            
            userService.sendUsedSugegstions()
        }
        
        talkService.updateTalkInArray(talk)
    }
    
    func showExpGain(earnedExp: Int) {
        let userLvl = lvlService.getUserLvl()
        let userExp = lvlService.getCurrentLvlExp()
        
        let expView = createExpView()
        showExpView(expView)
    }
    
    func createExpView() -> UIView {
        //create dimView
        let dimView = UIView(frame: self.initialViewFrame)
        dimView.backgroundColor = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1.0)
        dimView.alpha = 0
        self.view.addSubview(dimView)
        
        //create expView
        let expView = UIView(frame: self.initialViewFrame)
        expView.translatesAutoresizingMaskIntoConstraints = false
        expView.backgroundColor = UIColor.whiteColor()
        dimView.addSubview(expView)
        
        //add constraints
        let widthConstraint = NSLayoutConstraint(item: expView, attribute: .Width, relatedBy: .Equal,
            toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 200)
        expView.addConstraint(widthConstraint)
        
        let heightConstraint = NSLayoutConstraint(item: expView, attribute: .Height, relatedBy: .Equal,
            toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 100)
        expView.addConstraint(heightConstraint)
        
        let xConstraint = NSLayoutConstraint(item: expView, attribute: .CenterX, relatedBy: .Equal, toItem: self.view, attribute: .CenterX, multiplier: 1, constant: 0)
        self.view.addConstraint(xConstraint)
        
        let yConstraint = NSLayoutConstraint(item: expView, attribute: .CenterY, relatedBy: .Equal, toItem: self.view, attribute: .CenterY, multiplier: 1, constant: 0)
        self.view.addConstraint(yConstraint)
        
        //create avatar view
        let avatarView = UIImageView(frame: self.initialViewFrame)
        avatarView.translatesAutoresizingMaskIntoConstraints = false
        expView.addSubview(avatarView)
        
        //add constraints
        
        //exp gauge
        
        return dimView
    }
    
    func showExpView(expView: UIView) {
        //save view to clear it later
        self.expView = expView
        isExpViewShown = true
        
        UIView.animateWithDuration(
            0.5,
            delay: 0,
            options: [],
            animations: {
                expView.alpha = 0.5
            },
            completion: nil
        )
    }
    
    func removeExpView() {
        isExpViewShown = false
        
        UIView.animateWithDuration(
            0.5,
            delay: 0,
            options: [],
            animations: {
                self.expView?.alpha = 0
            },
            completion: { _ -> Void in
                self.expView?.removeFromSuperview()
            }
        )
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
        
        self.hideTopLayer()
        
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
                    options: [.Autoreverse, .Repeat, .AllowUserInteraction], animations: {
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
            return userService.getUserSuggestions()
        }
    }
    
    /*override func shouldAutorotate() -> Bool {
    return false
    }
    
    override func supportedInterfaceOrientations() -> Int {
    return UIInterfaceOrientation.Portrait.rawValue
    }*/
}
