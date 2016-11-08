//
//  SendMessageViewController.swift
//  WTFChat
//
//  Created by Artem Chuzhmarov on 05/10/15.
//  Copyright © 2015 Artem Chuzhmarov. All rights reserved.
//

import UIKit

class SendMessageViewController: UIViewController, CipherPickedComputer {
    fileprivate let messageCipherService: MessageCipherService = serviceLocator.get(MessageCipherService)

    @IBOutlet weak var messageWordsView: WordsViewController!
    
    @IBOutlet weak var cipherPicker: CipherPickerViewController!
    
    var text = ""
    var cipherType = CipherType.rightCutter
    var cipherDifficulty = CipherDifficulty.normal
    var message: Message!
    var isSingleMode = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        message = messageCipherService.createMessage(text, cipherType: cipherType, cipherDifficulty: cipherDifficulty)
        
        self.view.setNeedsLayout()
        self.view.layoutIfNeeded()
        
        cipherPicker.dataSource = cipherPicker
        cipherPicker.delegate = cipherPicker
        cipherPicker.updateCipher(cipherType, difficulty: cipherDifficulty)
        cipherPicker.cipherPickedComputer = self
        
        messageWordsView.dataSource = messageWordsView
        messageWordsView.delegate = messageWordsView
        messageWordsView.setNewMessage(message)

        cipherPicked(cipherType, difficulty: cipherDifficulty)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func cipherPicked(_ type: CipherType, difficulty: CipherDifficulty) {
        self.cipherType = type
        self.cipherDifficulty = difficulty
        
        message = messageCipherService.createMessage(text, cipherType: cipherType, cipherDifficulty: cipherDifficulty)
        
        messageWordsView.setNewMessage(message)
    }
    
    func sendTapped(_ sender: AnyObject) {
        performSegue(withIdentifier: "sendMessage", sender: self)
    }
}
