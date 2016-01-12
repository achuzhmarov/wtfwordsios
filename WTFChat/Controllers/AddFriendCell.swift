//
//  AddFriendCell.swift
//  WTFChat
//
//  Created by Artem Chuzhmarov on 26/09/15.
//  Copyright © 2015 Artem Chuzhmarov. All rights reserved.
//

import UIKit

class AddFriendCell: UITableViewCell {
    @IBOutlet weak var friendImage: UIImageView!
    @IBOutlet weak var friendLogin: UILabel!
    @IBOutlet weak var friendLvl: UILabel!
    @IBOutlet weak var friendName: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func initStyle() {
        friendImage.layer.borderColor = UIColor.whiteColor().CGColor
        friendImage.layer.cornerRadius = friendImage.bounds.width/2
        friendImage.clipsToBounds = true
        
        friendLogin.adjustsFontSizeToFitWidth = true
        friendName.adjustsFontSizeToFitWidth = true
        friendLvl.adjustsFontSizeToFitWidth = true
    }
    
    func updateFriend(friend: FriendInfo) {
        initStyle()

        friendLogin.text = friend.login.capitalizedString
        friendLvl.text = "lvl \(String(friend.lvl))"
        friendName.text = friend.name.capitalizedString
        
        friendImage.image = avatarService.getAvatarImage(friend.login,
            diameter: UInt(friendImage.bounds.height))
    }
}
