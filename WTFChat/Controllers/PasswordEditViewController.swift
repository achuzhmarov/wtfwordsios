//
//  PasswordEditViewController.swift
//  WTFChat
//
//  Created by Artem Chuzhmarov on 13/11/15.
//  Copyright © 2015 Artem Chuzhmarov. All rights reserved.
//

import Foundation

class PasswordEditViewController: UITableViewController, UITextFieldDelegate {
    @IBOutlet weak var oldPasswordText: UITextField!
    @IBOutlet weak var newPasswordText: UITextField!
    @IBOutlet weak var confirmPasswordText: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        oldPasswordText.delegate = self
        newPasswordText.delegate = self
        confirmPasswordText.delegate = self
        
        oldPasswordText.becomeFirstResponder()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func savePassword() {
        var valid = true
        
        if (oldPasswordText.text == nil || oldPasswordText.text == "") {
            oldPasswordText.placeholder = "Should not be empty"
            valid = false
        }
        
        if (newPasswordText.text == nil || newPasswordText.text == "") {
            newPasswordText.placeholder = "Should not be empty"
            valid = false
        }
        
        if (confirmPasswordText.text == nil || confirmPasswordText.text == "") {
            confirmPasswordText.placeholder = "Should not be empty"
            valid = false
        }
        
        if (newPasswordText.text != confirmPasswordText.text) {
            confirmPasswordText.text = ""
            confirmPasswordText.placeholder = "Passwords do not match"
            valid = false
        }
        
        if (!valid) {
            return
        }
        
        userService.updatePassword(oldPasswordText.text!, newPassword: newPasswordText.text!) { (error) -> Void in
            dispatch_async(dispatch_get_main_queue(), {
                if (error != nil) {
                    if (error!.code == HTTP_INCORRECT_PASSWORD) {
                        WTFOneButtonAlert.show("Error", message: "Wrong old password", firstButtonTitle: "Ok", viewPresenter: self)
                    } else {
                        WTFOneButtonAlert.show("Error", message: "Can't update user info. \(connectionErrorDescription())", firstButtonTitle: "Ok", viewPresenter: self)
                    }
                } else {
                    self.navigationController?.popViewControllerAnimated(true)
                }
            })
        }
    }
    
    @IBAction func saveTapped(sender: AnyObject) {
        savePassword()
    }
    
    //text field delegate method
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        savePassword()
        return true
    }
}