//
//  TutorialCell.swift
//  WTFChat
//
//  Created by Artem Chuzhmarov on 16/11/15.
//  Copyright © 2015 Artem Chuzhmarov. All rights reserved.
//

import UIKit

class RatingCell: UITableViewCell {
    fileprivate let currentUserService: CurrentUserService = serviceLocator.get(CurrentUserService.self)
    fileprivate let avatarService: AvatarService = serviceLocator.get(AvatarService.self)

    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var userLogin: UILabel!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var userLvl: UILabel!
    @IBOutlet weak var userNum: UILabel!
    @IBOutlet weak var userGlobalNum: UILabel!
    
    fileprivate func initStyle() {
        userImage.layer.borderColor = UIColor.white.cgColor
        userImage.layer.cornerRadius = userImage.bounds.width/2
        userImage.clipsToBounds = true
        
        userLogin.adjustsFontSizeToFitWidth = true
        userName.adjustsFontSizeToFitWidth = true
        userLvl.adjustsFontSizeToFitWidth = true
        userNum.adjustsFontSizeToFitWidth = true
        userGlobalNum?.adjustsFontSizeToFitWidth = true
    }
    
    func updateUser(_ user: FriendInfo, num: Int) {
        initStyle()

        userLogin.text = user.login.capitalized
        userName.text = user.name.capitalized
        userLvl.text = "lvl \(String(user.lvl))"
        
        if (user.exp == 0) {
            userNum.text = ""
            userGlobalNum?.text = ""
        } else {
            userNum?.text = String(user.rating)
            //userNum?.text = String(num)
            userGlobalNum?.text = String(user.rating)
        }
        
        userImage.image = avatarService.getImage(user.login,
            diameter: UInt(userImage.bounds.height))
        
        if (currentUserService.getUserLogin() == user.login) {
            self.backgroundColor = UIColor(netHex: 0xEEEEEE)
        } else {
            self.backgroundColor = UIColor.white
        }
    }
}
