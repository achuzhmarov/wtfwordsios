//
//  LoginViewController.swift
//  WTFChat
//
//  Created by Artem Chuzhmarov on 24/09/15.
//  Copyright © 2015 Artem Chuzhmarov. All rights reserved.
//

import UIKit

class LoginViewController: BaseLoginViewController, UITextFieldDelegate {
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        loginButton.layer.cornerRadius = 10
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(tap)
        
        usernameField.delegate = self
        passwordField.delegate = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func dismissKeyboard(){
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    @IBAction func loginButtonPressed(sender: AnyObject) {
        var valid = true
        
        if (usernameField.text == nil || usernameField.text == "") {
            usernameField.placeholder = "Login or email required"
            valid = false
        }
        
        if (passwordField.text == nil || passwordField.text == "") {
            passwordField.placeholder = "Password required"
            valid = false
        }
        
        if (valid) {
            self.login(usernameField.text!, password: passwordField.text!)
        }
    }
    
    //text fields delegate method
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        loginButtonPressed(loginButton)
        return true
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "restorePassword" {
            let targetController = segue.destinationViewController as! RestorePasswordViewController
            targetController.username = usernameField.text!
        }
        
        dismissKeyboard()
    }
}
