//
//  RestorePasswordViewController.swift
//  WTFChat
//
//  Created by Artem Chuzhmarov on 21/01/16.
//  Copyright © 2016 Artem Chuzhmarov. All rights reserved.
//

import UIKit

class RestorePasswordViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var usernameField: UITextField!
    
    var username = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sendButton.layer.cornerRadius = 10
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(RestorePasswordViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        usernameField.delegate = self
        
        usernameField.text = username
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func dismissKeyboard(){
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    @IBAction func sendButtonPressed(sender: AnyObject) {
        var valid = true
        
        if (usernameField.text == nil || usernameField.text == "") {
            usernameField.placeholder = "Login or email required"
            valid = false
        }
        
        if (valid) {
            sendEmailRequest()
        }
    }
    
    //text fields delegate method
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        sendButtonPressed(sendButton)
        return true
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "enterCode" {
            let targetController = segue.destinationViewController as! SetNewPasswordViewController
            targetController.username = usernameField.text!
        }
        
        dismissKeyboard()
    }
    
    private func sendEmailRequest() {
        authService.restorePassword(usernameField.text!) { error -> Void in
            dispatch_async(dispatch_get_main_queue(), {
                if let requestError = error {
                    if (requestError.code == HTTP_INCORRECT_LOGIN_OR_EMAIL) {
                        WTFOneButtonAlert.show("Error", message: "Incorrect login or email", firstButtonTitle: "Ok", viewPresenter: self)
                    } else {
                        WTFOneButtonAlert.show("Error", message: connectionErrorDescription(), firstButtonTitle: "Ok", viewPresenter: self)
                    }
                } else {
                    WTFOneButtonAlert.show("Success",
                        message: "You will soon recieve a email with restore code. Please, enter it on the next screen",
                        firstButtonTitle: "Ok",
                        viewPresenter: self) { () -> Void in
                            self.performSegueWithIdentifier("enterCode", sender: self)
                    }
                }
            })
        }
    }
}
