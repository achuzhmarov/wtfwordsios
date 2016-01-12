//
//  SendMessageViewController.swift
//  WTFChat
//
//  Created by Artem Chuzhmarov on 05/10/15.
//  Copyright © 2015 Artem Chuzhmarov. All rights reserved.
//

import UIKit

class SendMessageViewController: UIViewController, CipherPickedComputer {
    @IBOutlet weak var messageWordsView: WordsViewController!
    
    @IBOutlet weak var cipherPicker: CipherPickerViewController!
    
    @IBOutlet weak var levelRequiredLabel: UILabel!
    @IBOutlet weak var unlockCipherButton: UIButton!
    
    var text = ""
    var cipherType = CipherType.HalfWordRoundDown
    var message: Message!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        message = messageCipher.createMessage(text, cipherType: cipherType)
        
        self.view.setNeedsLayout()
        self.view.layoutIfNeeded()
        
        cipherPicker.dataSource = cipherPicker
        cipherPicker.delegate = cipherPicker
        cipherPicker.updateCipherType(cipherType)
        cipherPicker.cipherPickedComputer = self
        
        messageWordsView.dataSource = messageWordsView
        messageWordsView.delegate = messageWordsView
        messageWordsView.setNewMessage(message)
        
        levelRequiredLabel.textColor = FAILED_COLOR
        
        cipherPicked(cipherType)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "productPurchased:", name: IAPHelperProductPurchasedNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "productPurchasedError:", name: IAPHelperProductPurchasedErrorNotification, object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func cipherPicked(cipherType: CipherType) {
        self.cipherType = cipherType
        
        message = messageCipher.createMessage(text, cipherType: cipherType)
        
        messageWordsView.setNewMessage(message)
        
        if cipherService.canUseCipher(cipherType) {
            levelRequiredLabel.hidden = true
            unlockCipherButton.hidden = true
            
            let sendButton = UIBarButtonItem(title: "Send",
                style: UIBarButtonItemStyle.Plain, target: self, action: "sendTapped:")
            
            self.navigationItem.rightBarButtonItem = sendButton
        } else {
            if let cipherLvl = CipherFactory.getCipherLvl(cipherType) {
                levelRequiredLabel.text = "Level \(String(cipherLvl)) required"
            }
            
            levelRequiredLabel.hidden = false
            unlockCipherButton.hidden = false
            
            let tryButton = UIBarButtonItem(title: "Try it",
                style: UIBarButtonItemStyle.Plain, target: self, action: "tryTapped:")
            
            self.navigationItem.rightBarButtonItem = tryButton
        }
    }
    
    func sendTapped(sender: AnyObject) {
        performSegueWithIdentifier("sendMessage", sender: self)
    }
    
    func tryTapped(sender: AnyObject) {
        if adColonyService.hasAd() {
            adColonyService.showAd() { () -> Void in
                dispatch_async(dispatch_get_main_queue(), {
                    self.performSegueWithIdentifier("sendMessage", sender: self)
                })
            }
        } else {
            WTFOneButtonAlert.show("Error",
                message: "No ads available",
                firstButtonTitle: "Ok",
                viewPresenter: self)
        }
    }
    
    @IBAction func unlockCipherTapped(sender: AnyObject) {
        inAppService.showBuyAlert(IAPProducts.CIPHER_ALL, viewPresenter: self) { () -> Void in
            if let productId = CipherFactory.getProductId(self.cipherType) {
                inAppService.showBuyAlert(productId, viewPresenter: self)
            }
        }
    }
    
    func productPurchased(notification: NSNotification) {
        dispatch_async(dispatch_get_main_queue(), {
            self.cipherPicked(self.cipherType)
        })
    }
    
    func productPurchasedError(notification: NSNotification) {
        if (notification.object != nil) {
            let productIdentifier = notification.object as! String
            
            if let productTitle = inAppService.getProductTitle(productIdentifier) {
                dispatch_async(dispatch_get_main_queue(), {
                    self.cipherPicked(self.cipherType)
                    
                    WTFOneButtonAlert.show("Error",
                        message: "\(productTitle) purchase error",
                        firstButtonTitle: "Ok",
                        viewPresenter: self)
                })
            }
        } else {
            dispatch_async(dispatch_get_main_queue(), {
                self.cipherPicked(self.cipherType)
                
                WTFOneButtonAlert.show("Error",
                    message: "Unknown error occured",
                    firstButtonTitle: "Ok",
                    viewPresenter: self)
            })
        }
    }
}
