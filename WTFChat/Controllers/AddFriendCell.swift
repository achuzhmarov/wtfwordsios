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
    @IBOutlet weak var friendName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        friendImage.layer.borderColor = UIColor.whiteColor().CGColor
        friendImage.layer.cornerRadius = friendImage.frame.size.width/2
        friendImage.clipsToBounds = true
    }
}
