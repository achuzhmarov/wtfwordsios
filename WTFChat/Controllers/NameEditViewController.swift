//
//  NameEditViewController.swift
//  WTFChat
//
//  Created by Artem Chuzhmarov on 13/11/15.
//  Copyright © 2015 Artem Chuzhmarov. All rights reserved.
//

import Foundation

class NameEditViewController: UITableViewController, UITextFieldDelegate {
    
    @IBOutlet weak var nameText: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nameText.text = userService.getUserName()
        nameText.delegate = self
        nameText.becomeFirstResponder()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func saveName() {
        userService.updateName(nameText.text!) { (error) -> Void in
            dispatch_async(dispatch_get_main_queue(), {
                if (error != nil) {
                    WTFOneButtonAlert.show("Error", message: "Can't update user info. \(connectionErrorDescription())", firstButtonTitle: "Ok", viewPresenter: self)
                } else {
                    self.navigationController?.popViewControllerAnimated(true)
                }
            })
        }
    }
    
    @IBAction func saveTapped(sender: AnyObject) {
        saveName()
    }
    
    //text field delegate method
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        saveName()
        return true
    }
}