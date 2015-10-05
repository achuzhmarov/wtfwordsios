//
//  SendMessageViewController.swift
//  WTFChat
//
//  Created by Artem Chuzhmarov on 05/10/15.
//  Copyright © 2015 Artem Chuzhmarov. All rights reserved.
//

import UIKit

class SendMessageViewController: UIViewController {
    @IBOutlet weak var messageWordsView: WordsViewController!
    @IBOutlet weak var exampleWordsView: WordsViewController!
    
    @IBOutlet weak var cipherPicker: UIPickerView!
    
    @IBOutlet weak var cipherDescription: UILabel!
    
    var text = ""
    var cipherType = CipherType.HalfWordRoundDown
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}
