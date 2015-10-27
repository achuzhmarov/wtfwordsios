//
//  LoginViewController.swift
//  WTFChat
//
//  Created by Artem Chuzhmarov on 24/09/15.
//  Copyright © 2015 Artem Chuzhmarov. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        loginButton.layer.cornerRadius = 10
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "DismissKeyboard")
        view.addGestureRecognizer(tap)
        
        usernameField.delegate = self
        passwordField.delegate = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func DismissKeyboard(){
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    @IBAction func loginButtonPressed(sender: AnyObject) {
        var valid = true
        
        if (usernameField.text == nil || usernameField.text == "") {
            usernameField.placeholder = "Should not be empty"
            valid = false
        }
        
        if (passwordField.text == nil || passwordField.text == "") {
            passwordField.placeholder = "Should not be empty"
            valid = false
        }
        
        if (valid) {
            self.login(usernameField.text!, password: passwordField.text!)
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {   //delegate method
        loginButtonPressed(loginButton)
        return true
    }
    
    func login(login: String, password: String) {
        userService.login(login, password: password) { user, error -> Void in
            dispatch_async(dispatch_get_main_queue(), {
                if let requestError = error {
                    //TODO - show error to user
                    print(requestError)
                } else {
                    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                    appDelegate.showMainScreen()
                }
            })
        }
    }
    
    // MARK: - Navigation
    
    /*@IBAction func logout(segue:UIStoryboardSegue) {
        userService.logout()
        
        usernameField.text = ""
        usernameField.placeholder = "Username"
        passwordField.text = ""
        passwordField.placeholder = "Password"
        
        usernameField.resignFirstResponder()
        passwordField.resignFirstResponder()
    }*/
    
    @IBAction func register(segue:UIStoryboardSegue) {
        if let registrationController = segue.sourceViewController as? RegistrationViewController {
            login(registrationController.username, password: registrationController.password)
        }
    }
}
