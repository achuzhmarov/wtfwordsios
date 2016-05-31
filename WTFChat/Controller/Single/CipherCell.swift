//
//  TutorialCell.swift
//  WTFChat
//
//  Created by Artem Chuzhmarov on 16/11/15.
//  Copyright © 2015 Artem Chuzhmarov. All rights reserved.
//

import UIKit

class CipherCell: UITableViewCell {
    @IBOutlet weak var starImage: UIImageView!
    @IBOutlet weak var cipherText: UILabel!
    @IBOutlet weak var progressText: UILabel!

    private var cipherData: CipherData!

    func initStyle() {
        starImage.layer.borderColor = UIColor.whiteColor().CGColor
        starImage.layer.cornerRadius = starImage.bounds.width/2
        starImage.clipsToBounds = true

        cipherText.adjustsFontSizeToFitWidth = true
        progressText.adjustsFontSizeToFitWidth = true

        self.selectionStyle = .None;
    }
    
    func updateCipher(cipherData: CipherData) {
        initStyle()

        cipherText.text = cipherData.type.description
        progressText.text = String(cipherData.wins) + " / " + String(cipherData.maxStars)
        
        /*starImage.image = avatarService.getAvatarImage(user.login,
            diameter: UInt(userImage.bounds.height))*/
    }
}
