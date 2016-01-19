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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        emailText.text = currentUserService.getUserEmail()
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
        
        userService.updateEmail(emailText.text!) { (error) -> Void in
            dispatch_async(dispatch_get_main_queue(), {
                if (error != nil) {
                    if (error!.code == HTTP_EMAIL_EXISTS) {
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