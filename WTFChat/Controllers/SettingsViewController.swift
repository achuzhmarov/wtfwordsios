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
    
    override func viewWillAppear(animated: Bool) {
        updateUserInfo()
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
        
        self.tableView.reloadData()
    }
    
    @IBAction func pushNewChanged(sender: AnyObject) {
        userService.updatePushNew(pushNewSwitch.on) { (error) -> Void in
            dispatch_async(dispatch_get_main_queue(), {
                if (error != nil) {
                    WTFOneButtonAlert.show("Error", message: "Can't update user info. " + connectionErrorDescription(), firstButtonTitle: "Ok", viewPresenter: self)
                
                    self.pushNewSwitch.setOn(userService.getUserPushNew(), animated: true)
                }
            })
        }
    }
    
    @IBAction func pushDecipherChanged(sender: AnyObject) {
        userService.updatePushDeciphered(pushDecipherSwitch.on) { (error) -> Void in
            dispatch_async(dispatch_get_main_queue(), {
                if (error != nil) {
                    WTFOneButtonAlert.show("Error", message: "Can't update user info. " + connectionErrorDescription(), firstButtonTitle: "Ok", viewPresenter: self)
                
                    self.pushDecipherSwitch.setOn(userService.getUserPushDeciphered(), animated: true)
                }
            })
        }
    }
    
    let LOGOUT_SECTION = 5
    let LOGOUT_ROW = 0
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if (indexPath.section == LOGOUT_SECTION && indexPath.row == LOGOUT_ROW) {
            showLogoutAlert()
        }
    }
    
    func showLogoutAlert() {
        WTFTwoButtonsAlert.show("Logout",
            message: "Are you sure you want to logout?",
            firstButtonTitle: "Ok",
            secondButtonTitle: "Cancel",
            viewPresenter: self) { () -> Void in
                let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                appDelegate.logout()
        }
    }
}
