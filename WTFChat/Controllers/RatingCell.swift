//
//  RatingCell.swift
//  WTFChat
//
//  Created by Artem Chuzhmarov on 16/11/15.
//  Copyright © 2015 Artem Chuzhmarov. All rights reserved.
//

import UIKit

class RatingCell: UITableViewCell {
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var userLogin: UILabel!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var userLvl: UILabel!
    @IBOutlet weak var userNum: UILabel!
    @IBOutlet weak var userGlobalNum: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func initStyle() {
        userImage.layer.borderColor = UIColor.whiteColor().CGColor
        userImage.layer.cornerRadius = userImage.bounds.width/2
        userImage.clipsToBounds = true
        
        userLogin.adjustsFontSizeToFitWidth = true
        userName.adjustsFontSizeToFitWidth = true
        userLvl.adjustsFontSizeToFitWidth = true
        userNum.adjustsFontSizeToFitWidth = true
        userGlobalNum?.adjustsFontSizeToFitWidth = true
    }
    
    func updateUser(user: FriendInfo, num: Int) {
        initStyle()
        
        userLogin.text = user.login.capitalizedString
        userName.text = user.name.capitalizedString
        userLvl.text = "lvl \(String(user.lvl))"
        
        if (user.exp == 0) {
            userNum.text = ""
            userGlobalNum?.text = ""
        } else {
            userNum.text = String(num)
            userGlobalNum?.text = String(user.rating)
        }
        
        userImage.image = avatarService.getAvatarImage(user.login,
            diameter: UInt(userImage.bounds.height))
        
        if (userService.getUserLogin() == user.login) {
            self.backgroundColor = UIColor(netHex: 0xEEEEEE)
        } else {
            self.backgroundColor = UIColor.whiteColor()
        }
    }
}
