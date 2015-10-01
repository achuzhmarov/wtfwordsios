//
//  LoginViewController.swift
//  WTFChat
//
//  Created by Artem Chuzhmarov on 24/09/15.
//  Copyright © 2015 Artem Chuzhmarov. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    var user: User?
    
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    let keychain = KeychainWrapper()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        loginButton.layer.cornerRadius = 10
        
        let username = keychain.myObjectForKey(kSecAttrAccount) as? String
        let password = keychain.myObjectForKey(kSecValueData) as? String
        
        if (username != nil && password != nil && username != "Not set") {
            usernameField.text = username
            passwordField.text = password
            login(username!, password: password!)
        }
        
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
    
    func login(login: String, password: String) {
        userService.login(login, password: password) { user, error -> Void in
            dispatch_async(dispatch_get_main_queue(), {
                if let requestError = error {
                    self.keychain.resetKeychainItem()
                    
                    //TODO - show error to user
                    print(requestError)
                } else {
                    self.user = user
                    userService.currentUser = self.user
                    
                    self.keychain.mySetObject(login, forKey:kSecAttrAccount)
                    self.keychain.mySetObject(password, forKey:kSecValueData)
                    self.keychain.writeToKeychain()
                    
                    self.performSegueWithIdentifier("showFriends", sender: self)
                }
            })
        }
    }
    
    // MARK: - Navigation
    
    @IBAction func logout(segue:UIStoryboardSegue) {
        userService.logout()
        
        usernameField.text = ""
        usernameField.placeholder = "Username"
        passwordField.text = ""
        passwordField.placeholder = "Password"
        
        usernameField.resignFirstResponder()
        passwordField.resignFirstResponder()
        
        self.keychain.mySetObject("Not set", forKey:kSecAttrAccount)
        self.keychain.mySetObject("Not set", forKey:kSecValueData)
        self.keychain.writeToKeychain()

    }
    
    @IBAction func register(segue:UIStoryboardSegue) {
        if let registrationController = segue.sourceViewController as? RegistrationViewController {
            login(registrationController.username, password: registrationController.password)
        }
    }
}
