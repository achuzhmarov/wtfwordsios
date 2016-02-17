//
//  TutorialDecipherViewController.swift
//  WTFChat
//
//  Created by Artem Chuzhmarov on 12/01/16.
//  Copyright © 2016 Artem Chuzhmarov. All rights reserved.
//

import Foundation

class TutorialDecipherViewController: DecipherViewController {
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if (currentTutorialStage == .ResponseAquired) {
            WTFOneButtonAlert.show("Details",
                message: "Here is my progress. You can tap anywhere to see the message in its cipher form. When you finished, please, go back to 'Tutorial' screen.",
                firstButtonTitle: "Ok",
                viewPresenter: self) { () -> Void in
                    currentTutorialStage = .DetailsViewed
            }
        }
    }
    
    override func start() {
        super.start()
        
        if (currentTutorialStage == .Started) {
            isPaused = true
            
            WTFOneButtonAlert.show("Decipher",
                message: "To decipher a message you have to enter your guesses for ciphered words. Try to type 'to' and press either 'Try' or 'Enter' button.",
                firstButtonTitle: "Ok",
                viewPresenter: self) { () -> Void in
                    self.isPaused = false
                    currentTutorialStage = .DecipherGuess
            }
        }
    }
    
    override func gameOver() {
        super.gameOver()
        
        if (currentTutorialStage == .DecipherRest) {
            topViewHeightContraint.constant = initialTopViewHeightConstraintConstant
            self.expGainView.myInit(self.topView)
            
            //just some random exp value
            self.expGainView.runProgress(55)
            
            WTFOneButtonAlert.show("",
                message: "Yay! You have deciphered your first message. In online mode you will gain XP for it. Remember, if you have deciphered all words in a message (no red) - you will get an x3 XP bonus! Now, please, return to the previous screen ('Tutorial' button at left top corner).",
                firstButtonTitle: "Ok",
                viewPresenter: self) { () -> Void in
                    currentTutorialStage = .Deciphered
            }
        }
    }
    
    override func tryButtonPressed(sender: AnyObject) {
        switch (currentTutorialStage) {
        case .DecipherGuess:
            if (guessTextField.text!.uppercaseString == "TO") {
                super.tryButtonPressed(sender)
                
                self.isPaused = true
                
                WTFOneButtonAlert.show("",
                    message: "Congratulations! You have just deciphered your first word! Now, enter 'chart' as your next guess.",
                    firstButtonTitle: "Ok",
                    viewPresenter: self) { () -> Void in
                        self.isPaused = false
                        currentTutorialStage = .DecipherCloseTry
                }
            } else {
                showWrongActionAlert()
            }
        case .DecipherCloseTry:
            if (guessTextField.text!.uppercaseString == "CHART") {
                super.tryButtonPressed(sender)
                
                self.isPaused = true
                
                WTFOneButtonAlert.show("",
                    message: "Oh! You were close! See how the word 'Ch...!' has changed color. It is orange now. You can try other guesses to get clear green result. But for the sake of the tutorial, try tapping on it to decipher!",
                    firstButtonTitle: "Ok",
                    viewPresenter: self) { () -> Void in
                        self.isPaused = false
                        currentTutorialStage = .DecipherCloseTryHint
                }
            } else {
                showWrongActionAlert()
            }
        case .DecipherCloseTryHint:
            showWrongActionAlert()
        case .DecipherHint:
            showWrongActionAlert()
        default:
            super.tryButtonPressed(sender)
        }
    }
    
    override func giveUpButtonPressed(sender: AnyObject) {
        switch (currentTutorialStage) {
        case .DecipherGuess:
            showWrongActionAlert()
        case .DecipherCloseTry:
            showWrongActionAlert()
        case .DecipherCloseTryHint:
            showWrongActionAlert()
        case .DecipherHint:
            showWrongActionAlert()
        default:
            super.giveUpButtonPressed(sender)
        }
    }
    
    override func useSuggestion(word: Word) {
        switch (currentTutorialStage) {
        case .DecipherGuess:
            showWrongActionAlert()
        case .DecipherCloseTry:
            showWrongActionAlert()
        case .DecipherCloseTryHint:
            if (word.wasCloseTry) {
                super.useSuggestion(word)
                
                self.isPaused = true
                
                WTFOneButtonAlert.show("",
                    message: "Wow, it worked! Now, try to use a similar action to get a hint for any blue word.",
                    firstButtonTitle: "Ok",
                    viewPresenter: self) { () -> Void in
                        self.isPaused = false
                        currentTutorialStage = .DecipherHint
                }
            } else {
                showWrongActionAlert()
            }
        case .DecipherHint:
            super.useSuggestion(word)
            
            self.isPaused = true
            
            WTFOneButtonAlert.show("",
                message: "You see? You have a number of hints you can use to immediately decipher any blue word! Awesome, isn't it? Try to decipher the rest of the message by yourself.",
                firstButtonTitle: "Ok",
                viewPresenter: self) { () -> Void in
                    self.isPaused = false
                    currentTutorialStage = .DecipherRest
            }
        default:
            super.useSuggestion(word)
        }
    }
    
    private func showWrongActionAlert() {
        switch (currentTutorialStage) {
        case .DecipherGuess:
            self.isPaused = true
            
            WTFOneButtonAlert.show("",
                message: "Please, type 'to' and press 'Try'!",
                firstButtonTitle: "Ok",
                viewPresenter: self) { () -> Void in
                    self.isPaused = false
            }
        case .DecipherCloseTry:
            self.isPaused = true
            
            WTFOneButtonAlert.show("",
                message: "Please, type 'chart' and press 'Try'!",
                firstButtonTitle: "Ok",
                viewPresenter: self) { () -> Void in
                    self.isPaused = false
            }
        case .DecipherCloseTryHint:
            self.isPaused = true
            
            WTFOneButtonAlert.show("",
                message: "Please, tap on the orange word bubble to open it!",
                firstButtonTitle: "Ok",
                viewPresenter: self) { () -> Void in
                    self.isPaused = false
            }
        case .DecipherHint:
            self.isPaused = true
            
            WTFOneButtonAlert.show("",
                message: "Please, tap on any blue word bubble and use a hint!",
                firstButtonTitle: "Ok",
                viewPresenter: self) { () -> Void in
                    self.isPaused = false
            }
        default: return
        }
    }
    
    override func sendMessageUpdate() {
        switch (currentTutorialStage) {
        case .Never, .Skipped, .Finished:
            super.sendMessageUpdate()
        default:
            return
        }
    }
    
    override func sendMessageDecipher() {
        switch (currentTutorialStage) {
        case .Never, .Skipped, .Finished:
            super.sendMessageDecipher()
        default:
            return
        }
    }
    
    override func showNoSuggestionsDialog() {
        WTFOneButtonAlert.show("Hints remained: 0",
            message: "You have used all hints",
            firstButtonTitle: "Ok",
            viewPresenter: self)
    }
}