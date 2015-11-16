//
//  RegistrationViewController.swift
//  WTFChat
//
//  Created by Artem Chuzhmarov on 25/09/15.
//  Copyright © 2015 Artem Chuzhmarov. All rights reserved.
//

import UIKit

class RegistrationViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var passwordConfirmField: UITextField!
    
    @IBOutlet weak var signUpButton: UIButton!
    
    var username = ""
    var password = ""
    var email = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        signUpButton.layer.cornerRadius = 10
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "DismissKeyboard")
        view.addGestureRecognizer(tap)
        
        usernameField.delegate = self
        emailField.delegate = self
        passwordField.delegate = self
        passwordConfirmField.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func DismissKeyboard(){
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }

    func register() {
        if (!checkData()) {
            return
        }
        
        self.username = usernameField.text!
        self.password = passwordField.text!
        self.email = emailField.text!
        
        userService.register(username, password: password, email: email) { error -> Void in
            dispatch_async(dispatch_get_main_queue(), {
                if let requestError = error {
                    //conflict
                    if (requestError.code == HTTP_LOGIN_EXISTS) {
                        self.usernameField.text = ""
                        self.usernameField.placeholder = self.username + " already exists"
                        
                        WTFOneButtonAlert.show("Error",
                            message: "Login " + self.username + " already exists",
                            firstButtonTitle: "Ok",
                            viewPresenter: self)
                        
                    } else if (requestError.code == HTTP_EMAIL_EXISTS) {
                        self.emailField.text = ""
                        self.emailField.placeholder = self.email + " already exists"
                        
                        WTFOneButtonAlert.show("Error",
                            message: "Email " + self.email + " already exists",
                            firstButtonTitle: "Ok",
                            viewPresenter: self)
                        
                    } else {
                        WTFOneButtonAlert.show("Error",
                            message: connectionErrorDescription(),
                            firstButtonTitle: "Ok",
                            viewPresenter: self)
                    }
                } else {
                    self.performSegueWithIdentifier("register", sender: self)
                }
            })
        }
    }
    
    func checkData() -> Bool {
        var valid = true
        
        if (usernameField.text == nil || usernameField.text == "") {
            usernameField.placeholder = "Login required"
            valid = false
        }
        
        if (emailField.text == nil || emailField.text == "") {
            emailField.placeholder = "Email required"
            valid = false
        } else if (!isValidEmail(emailField.text!)) {
            emailField.textColor = UIColor.redColor()
            emailField.placeholder = "Invalid email address"
            valid = false
        } else {
            emailField.textColor = UIColor.blackColor()
        }
        
        if (passwordField.text == nil || passwordField.text == "") {
            passwordField.placeholder = "Password required"
            valid = false
        }
        
        if (passwordConfirmField.text == nil || passwordConfirmField.text == "") {
            passwordConfirmField.placeholder = "Confirm password required"
            valid = false
        }
        
        if (passwordField.text != passwordConfirmField.text) {
            passwordConfirmField.text = ""
            passwordConfirmField.placeholder = "Passwords do not match"
            valid = false
        }
        
        return valid
    }
    
    //text fields delegate method
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        register()
        return true
    }
    
    @IBAction func signButtonPressed(sender: AnyObject) {
        register()
    }
}
