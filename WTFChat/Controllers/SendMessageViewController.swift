//
//  SendMessageViewController.swift
//  WTFChat
//
//  Created by Artem Chuzhmarov on 05/10/15.
//  Copyright © 2015 Artem Chuzhmarov. All rights reserved.
//

import UIKit

let EXAMPLE_CIPHER_WORD = Word(text: "Welcome", additional: "!")

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
                levelRequiredLabel.text = "Level " + String(cipherLvl) + " required"
            }
            
            levelRequiredLabel.hidden = false
            unlockCipherButton.hidden = false
            
            let tryButton = UIBarButtonItem(title: "Try it",
                style: UIBarButtonItemStyle.Plain, target: self, action: "tryTapped:")
            
            self.navigationItem.rightBarButtonItem = tryButton
        }
    }
    
    func sendTapped(sender: AnyObject) {
        print("send tapped")
        
        performSegueWithIdentifier("sendMessage", sender: self)
    }
    
    func tryTapped(sender: AnyObject) {
        print("try tapped")
        
        //TODO - replace with show add
        performSegueWithIdentifier("sendMessage", sender: self)
    }
}
