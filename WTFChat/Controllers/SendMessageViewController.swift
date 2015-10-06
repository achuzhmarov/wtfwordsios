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
    
    @IBOutlet weak var exampleLabel: RoundedLabel!
    
    var text = ""
    var cipherType = CipherType.HalfWordRoundDown
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let message = messageCipher.createMessage(text, cipherType: cipherType)
        
        self.view.setNeedsLayout()
        self.view.layoutIfNeeded()
        
        cipherPicker.dataSource = cipherPicker
        cipherPicker.delegate = cipherPicker
        cipherPicker.updateCipherType(cipherType)
        cipherPicker.cipherPickedComputer = self
        
        messageWordsView.dataSource = messageWordsView
        messageWordsView.delegate = messageWordsView
        messageWordsView.setNewMessage(message)
        
        setExampleLabel()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func cipherPicked(cipherType: CipherType) {
        self.cipherType = cipherType
        
        let message = messageCipher.createMessage(text, cipherType: cipherType)
        
        messageWordsView.setNewMessage(message)
        setExampleLabel()
    }
    
    func setExampleLabel() {
        exampleLabel.text = CipherFactory.cipherText(
            self.cipherType,
            word: EXAMPLE_CIPHER_WORD
        )
        
        exampleLabel.textColor = UIColor.whiteColor()
        exampleLabel.font = UIFont(name: exampleLabel.font.fontName, size: 12)
        exampleLabel.layer.backgroundColor = CIPHERED_COLOR.CGColor
        
        //to make cornerRadius work
        exampleLabel.layer.masksToBounds = true;
        exampleLabel.layer.cornerRadius = 8.0;
        
        exampleLabel.translatesAutoresizingMaskIntoConstraints = false
        exampleLabel.userInteractionEnabled = true
        exampleLabel.sizeToFit()
    }
}
