//
//  RegistrationViewController.swift
//  WTFChat
//
//  Created by Artem Chuzhmarov on 25/09/15.
//  Copyright © 2015 Artem Chuzhmarov. All rights reserved.
//

import UIKit

class RegistrationViewController: UIViewController {
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var passwordConfirmField: UITextField!
    @IBOutlet weak var signUpButton: UIButton!
    
    var username = ""
    var password = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        signUpButton.layer.cornerRadius = 10
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "DismissKeyboard")
        view.addGestureRecognizer(tap)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func DismissKeyboard(){
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    @IBAction func signButtonPressed(sender: AnyObject) {
        var valid = true
        
        if (usernameField.text == nil || usernameField.text == "") {
            usernameField.placeholder = "Should not be empty"
            valid = false
        }
        
        if (passwordField.text == nil || passwordField.text == "") {
            passwordField.placeholder = "Should not be empty"
            valid = false
        }
        
        if (passwordConfirmField.text == nil || passwordConfirmField.text == "") {
            passwordConfirmField.placeholder = "Should not be empty"
            valid = false
        }
        
        if (passwordField.text != passwordConfirmField.text) {
            passwordConfirmField.text = ""
            passwordConfirmField.placeholder = "Passwords do not match"
            valid = false
        }
        
        if (valid) {
            self.register(usernameField.text!, password: passwordField.text!)
        }
    }
    
    func register(username: String, password: String) {
        self.username = username
        self.password = password
        
        userService.register(username, password: password) { error -> Void in
            dispatch_async(dispatch_get_main_queue(), {
                if let requestError = error {
                    //conflict
                    if (requestError.code == 409) {
                        self.usernameField.text = ""
                        self.usernameField.placeholder = self.username + " already exists"
                    } else {
                        print(requestError)
                    }
                } else {
                    self.performSegueWithIdentifier("register", sender: self)
                }
            })
        }
    }
}
