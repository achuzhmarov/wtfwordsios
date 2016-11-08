//
//  NameEditViewController.swift
//  WTFChat
//
//  Created by Artem Chuzhmarov on 13/11/15.
//  Copyright © 2015 Artem Chuzhmarov. All rights reserved.
//

import Foundation

class NameEditViewController: UITableViewController, UITextFieldDelegate {
    fileprivate let userService: UserService = serviceLocator.get(UserService.self)
    fileprivate let currentUserService: CurrentUserService = serviceLocator.get(CurrentUserService.self)

    @IBOutlet weak var nameText: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nameText.text = currentUserService.getUserName()
        nameText.delegate = self
        nameText.becomeFirstResponder()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func saveName() {
        userService.updateName(nameText.text!) { (error) -> Void in
            DispatchQueue.main.async(execute: {
                if (error != nil) {
                    WTFOneButtonAlert.show("Error", message: "Can't update user info. \(WTFOneButtonAlert.CON_ERR)", firstButtonTitle: "Ok")
                } else {
                    _ = self.navigationController?.popViewController(animated: true)
                }
            })
        }
    }
    
    @IBAction func saveTapped(_ sender: AnyObject) {
        saveName()
    }
    
    //text field delegate method
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        saveName()
        return true
    }
}
