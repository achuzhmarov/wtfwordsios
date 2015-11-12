//
//  SettingsViewController.swift
//  WTFChat
//
//  Created by Artem Chuzhmarov on 11/11/15.
//  Copyright © 2015 Artem Chuzhmarov. All rights reserved.
//

import UIKit

class SettingsViewController: UITableViewController {

    @IBOutlet weak var userImage: UIImageView!
    
    @IBOutlet weak var loginText: UILabel!
    
    @IBOutlet weak var lvlText: UILabel!
    @IBOutlet weak var lvlProgress: UIProgressView!
    
    @IBOutlet weak var hintsText: UILabel!
    
    @IBOutlet weak var nameText: UILabel!
    @IBOutlet weak var emailText: UILabel!
    
    @IBOutlet weak var logoutText: UILabel!
    
    @IBOutlet weak var pushNewSwitch: UISwitch!
    @IBOutlet weak var pushDecipherSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        logoutText.textColor = FAILED_COLOR
        
        userImage.layer.borderColor = UIColor.whiteColor().CGColor
        userImage.layer.cornerRadius = userImage.bounds.width/2
        userImage.clipsToBounds = true
        
        updateUserInfo()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func updateUserInfo() {
        loginText.text = userService.getUserLogin()
        
        lvlText.text = String(userService.getUserLvl())
        lvlProgress.progress = Float(lvlService.getCurrentLvlExp()) / Float(lvlService.getNextLvlExp())
        
        hintsText.text = String(userService.getUserSuggestions())
        
        nameText.text = userService.getUserName()
        emailText.text = userService.getUserEmail()
        
        pushNewSwitch.setOn(userService.getUserPushNew(), animated: false)
        pushDecipherSwitch.setOn(userService.getUserPushDeciphered(), animated: false)
        
        userImage.image = avatarService.getAvatarImage(
            userService.getUserLogin(),
            diameter: UInt(userImage.bounds.height))
    }
    
    @IBAction func pushNewChanged(sender: AnyObject) {
        
    }
    
    @IBAction func pushDecipherChanged(sender: AnyObject) {
        
    }
}
