//
//  TutorialCell.swift
//  WTFChat
//
//  Created by Artem Chuzhmarov on 16/11/15.
//  Copyright © 2015 Artem Chuzhmarov. All rights reserved.
//

import UIKit

class CipherCell: UITableViewCell {
    @IBOutlet weak var starImage: StarImage!
    @IBOutlet weak var cipherText: UILabel!
    //@IBOutlet weak var progressText: UILabel!

    private var cipherData: CipherData!

    func initStyle() {
        //cipherText.adjustsFontSizeToFitWidth = true
        //progressText.adjustsFontSizeToFitWidth = true

        self.selectionStyle = .None;
    }
    
    func updateCipher(cipherData: CipherData) {
        initStyle()

        cipherText.text = cipherData.type.description

        if (cipherData.wins < cipherData.maxStars) {
            //progressText.text = String(cipherData.maxStars - cipherData.wins)
            self.backgroundColor = UIColor.whiteColor()
        } else {
            //progressText.text = ""
            self.backgroundColor = StarImage.lightGoldColor
        }

        starImage.updateStarImage(cipherData.wins, max: cipherData.maxStars)
    }
}
