//
//  SettingsViewController.swift
//  WTFChat
//
//  Created by Artem Chuzhmarov on 11/11/15.
//  Copyright © 2015 Artem Chuzhmarov. All rights reserved.
//

import UIKit

class SettingsViewController: UITableViewController {
    fileprivate let userService: UserService = serviceLocator.get(UserService)
    fileprivate let currentUserService: CurrentUserService = serviceLocator.get(CurrentUserService)
    fileprivate let avatarService: AvatarService = serviceLocator.get(AvatarService)

    @IBOutlet weak var userImage: UIImageView!
    
    @IBOutlet weak var loginText: UILabel!
    
    @IBOutlet weak var lvlText: UILabel!
    @IBOutlet weak var lvlProgress: UIProgressView!
    
    @IBOutlet weak var hintsText: UILabel!
    
    @IBOutlet weak var nameText: UILabel!
    
    @IBOutlet weak var pushNewSwitch: UISwitch!
    @IBOutlet weak var pushDecipherSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        userImage.layer.borderColor = UIColor.white.cgColor
        userImage.layer.cornerRadius = userImage.bounds.width/2
        userImage.clipsToBounds = true
        
        updateUserInfo()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        updateUserInfo()
    }
    
    func updateUserInfo() {
        loginText.text = currentUserService.getUserLogin()
        
        lvlText.text = String(currentUserService.getUserLvl())
        lvlProgress.progress = Float(currentUserService.getCurrentLvlExp()) / Float(currentUserService.getNextLvlExp())
        
        hintsText.text = String(currentUserService.getUserHints())
        
        nameText.text = currentUserService.getUserName()
        
        pushNewSwitch.setOn(currentUserService.getUserPushNew(), animated: false)
        pushDecipherSwitch.setOn(currentUserService.getUserPushDeciphered(), animated: false)
        
        userImage.image = avatarService.getImage(
            currentUserService.getUserLogin(),
            diameter: UInt(userImage.bounds.height))
        
        self.tableView.reloadData()
    }
    
    @IBAction func pushNewChanged(_ sender: AnyObject) {
        userService.updatePushNew(pushNewSwitch.isOn) { (error) -> Void in
            DispatchQueue.main.async(execute: {
                if (error != nil) {
                    WTFOneButtonAlert.show("Error", message: "Can't update user info. \(WTFOneButtonAlert.CON_ERR)", firstButtonTitle: "Ok")
                
                    self.pushNewSwitch.setOn(self.currentUserService.getUserPushNew(), animated: true)
                }
            })
        }
    }
    
    @IBAction func pushDecipherChanged(_ sender: AnyObject) {
        userService.updatePushDeciphered(pushDecipherSwitch.isOn) { (error) -> Void in
            DispatchQueue.main.async(execute: {
                if (error != nil) {
                    WTFOneButtonAlert.show("Error", message: "Can't update user info. \(WTFOneButtonAlert.CON_ERR)", firstButtonTitle: "Ok")
                
                    self.pushDecipherSwitch.setOn(self.currentUserService.getUserPushDeciphered(), animated: true)
                }
            })
        }
    }
}
