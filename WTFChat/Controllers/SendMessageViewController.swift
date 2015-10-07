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
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func cipherPicked(cipherType: CipherType) {
        self.cipherType = cipherType
        
        let message = messageCipher.createMessage(text, cipherType: cipherType)
        
        messageWordsView.setNewMessage(message)
    }
}
