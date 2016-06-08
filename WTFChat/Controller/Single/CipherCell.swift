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
    
    func updateSingleTalk(singleTalk: SingleTalk) {
        initStyle()

        cipherText.text = singleTalk.cipherType.description

        if (singleTalk.wins < singleTalk.cipherSettings!.maxStars) {
            self.backgroundColor = UIColor.whiteColor()
        } else {
            self.backgroundColor = StarImage.lightGoldColor
        }

        starImage.updateStarImage(singleTalk.wins, max: singleTalk.cipherSettings!.maxStars)
    }
}
