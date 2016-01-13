//
//  TutorialDecipherViewController.swift
//  WTFChat
//
//  Created by Artem Chuzhmarov on 12/01/16.
//  Copyright © 2016 Artem Chuzhmarov. All rights reserved.
//

import Foundation

class TutorialDecipherViewController: DecipherViewController {
    override func sendMessageUpdate() {
        //do nothing
    }
    
    override func sendMessageDecipher() {
        //do nothing
    }
    
    override func start() {
        super.start()
        
        isPaused = true
        
        WTFOneButtonAlert.show("Decipher",
            message: "To decipher a message you have to enter your guesses for ciphered words. Try to type 'to' and press either 'Try' or 'enter' button",
            firstButtonTitle: "Ok",
            viewPresenter: self) { () -> Void in
                self.isPaused = false
                currentTutorialStage = .DecipherGuess
        }
    }
    
    override func gameOver() {
        super.gameOver()
        
        topViewHeightContraint.constant = initialTopViewHeightConstraintConstant
        self.expGainView.myInit(self.topView)
        
        //just some random exp value
        self.expGainView.runProgress(55)
        
        WTFOneButtonAlert.show("",
            message: "Yay! You have deciphered your first message. In online mode you will gain XP for it. Remember, if you deciphered all words in a message (all green) - you will get an x3 XP bonus! Now, please, return to previous screen ('Tutorial' button at left top corner)",
            firstButtonTitle: "Ok",
            viewPresenter: self) { () -> Void in
                currentTutorialStage = .Deciphered
        }
    }
    
    override func tryButtonPressed(sender: AnyObject) {
        switch (currentTutorialStage) {
        case .DecipherGuess:
            if (guessTextField.text!.uppercaseString == "TO") {
                super.tryButtonPressed(sender)
                
                self.isPaused = true
                
                WTFOneButtonAlert.show("",
                    message: "Congratulation! You have just deciphered your first word! Now, let's enter 'chart' as an our next guess",
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
                    message: "Oh! We were close! Now word 'Ch...!' have orange color. You can try another guesses to get clear green result. But for the sake of the tutorial, let's try to tap on it to decipher it!",
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
                    message: "Wow, it actually worked! Now, let's try to use a similar hint on any blue word",
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
                message: "You see? You have a number of hints you can use to immidiately decipher any blue word! Awesome, isn't it? Try to decipher the rest of the message by yourself",
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
                message: "Please, tap on the orange word bubble and decipher it!",
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
}