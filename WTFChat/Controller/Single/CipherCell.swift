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

    private var cipherData: CipherSettings!

    func initStyle() {
        self.selectionStyle = .None;
    }
    
    func updateCipher(cipherTalk: SingleTalk) {
        initStyle()

        cipherText.text = cipherTalk.cipherType.description

        if (cipherTalk.wins < cipherTalk.cipherSettings!.maxStars) {
            self.backgroundColor = UIColor.whiteColor()
        } else {
            self.backgroundColor = StarImage.lightGoldColor
        }

        starImage.updateStarImage(cipherTalk.wins, max: cipherTalk.cipherSettings!.maxStars)
    }
}
