//
//  SetNewPasswordViewController.swift
//  WTFChat
//
//  Created by Artem Chuzhmarov on 21/01/16.
//  Copyright © 2016 Artem Chuzhmarov. All rights reserved.
//

import UIKit

class SetNewPasswordViewController: BaseLoginViewController, UITextFieldDelegate {
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var codeField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var passwordConfirmField: UITextField!
    
    @IBOutlet weak var changeButton: UIButton!
    
    var username = ""
    var password = ""
    var code = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        changeButton.layer.cornerRadius = 10
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(SetNewPasswordViewController.DismissKeyboard))
        view.addGestureRecognizer(tap)
        
        usernameField.delegate = self
        codeField.delegate = self
        passwordField.delegate = self
        passwordConfirmField.delegate = self
        
        usernameField.text = username
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func DismissKeyboard(){
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    func changePassword() {
        if (!checkData()) {
            return
        }
        
        self.username = usernameField.text!
        self.password = passwordField.text!
        self.code = codeField.text!
        
        authService.changePassword(username, password: password, code: code) { error -> Void in
            dispatch_async(dispatch_get_main_queue(), {
                if let requestError = error {
                    if (requestError.code == HTTP_INCORRECT_LOGIN_OR_EMAIL) {
                        WTFOneButtonAlert.show("Error", message: "Incorrect login or email", firstButtonTitle: "Ok", viewPresenter: self)
                    } else if (requestError.code == HTTP_RESTORE_CODE_INVALID) {
                        self.codeField.text = ""
                        self.codeField.placeholder = "Invalid restore code"
                        
                        WTFOneButtonAlert.show("Error",
                            message: "Invalid restore code",
                            firstButtonTitle: "Ok",
                            viewPresenter: self)
                        
                    } else {
                        WTFOneButtonAlert.show("Error",
                            message: connectionErrorDescription(),
                            firstButtonTitle: "Ok",
                            viewPresenter: self)
                    }
                } else {
                    self.login(self.username, password: self.password)
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
        
        if (codeField.text == nil || codeField.text == "") {
            codeField.placeholder = "Code required"
            valid = false
        } else {
            codeField.textColor = UIColor.blackColor()
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
        changePassword()
        return true
    }
    
    @IBAction func changeButtonPressed(sender: AnyObject) {
        changePassword()
    }
}
