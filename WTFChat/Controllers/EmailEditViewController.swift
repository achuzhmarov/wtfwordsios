//
//  EmailEditViewController.swift
//  WTFChat
//
//  Created by Artem Chuzhmarov on 13/11/15.
//  Copyright © 2015 Artem Chuzhmarov. All rights reserved.
//

import Foundation

class EmailEditViewController: UITableViewController, UITextFieldDelegate {
    
    @IBOutlet weak var emailText: UITextField!
    @IBOutlet weak var passwordText: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        emailText.text = currentUserService.getUserEmail()
        
        passwordText.delegate = self
        emailText.delegate = self
        emailText.becomeFirstResponder()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func saveEmail() {
        if (emailText.text == nil || emailText.text == "") {
            emailText.placeholder = "Should not be empty"
            return
        }
        
        if (!isValidEmail(emailText.text!)) {
            emailText.placeholder = "Invalid email address"
            return
        }
        
        if (passwordText.text == nil || passwordText.text == "") {
            passwordText.placeholder = "Should not be empty"
            return
        }
        
        userService.updateEmail(emailText.text!, password: passwordText.text!) { (error) -> Void in
            dispatch_async(dispatch_get_main_queue(), {
                if (error != nil) {
                    if (error!.code == HTTP_INCORRECT_PASSWORD) {
                        WTFOneButtonAlert.show("Error", message: "Incorrect password", firstButtonTitle: "Ok", viewPresenter: self)
                    } else if (error!.code == HTTP_EMAIL_EXISTS) {
                        WTFOneButtonAlert.show("Error", message: "User with this email already exists", firstButtonTitle: "Ok", viewPresenter: self)
                    } else {
                        WTFOneButtonAlert.show("Error", message: "Can't update user info. \( connectionErrorDescription())", firstButtonTitle: "Ok", viewPresenter: self)
                    }
                } else {
                    self.navigationController?.popViewControllerAnimated(true)
                }
            })
        }
    }
    
    @IBAction func saveTapped(sender: AnyObject) {
        saveEmail()
    }
    
    //text field delegate method
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        saveEmail()
        return true
    }
}