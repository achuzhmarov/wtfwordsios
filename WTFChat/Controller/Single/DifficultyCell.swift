//
//  TutorialCell.swift
//  WTFChat
//
//  Created by Artem Chuzhmarov on 16/11/15.
//  Copyright © 2015 Artem Chuzhmarov. All rights reserved.
//

import UIKit

class DifficultyCell: UITableViewCell {
    @IBOutlet weak var title: UILabel!

    func initStyle() {
        title.adjustsFontSizeToFitWidth = true
        self.backgroundColor = UIColor(netHex: 0xEEEEEE)

        self.selectionStyle = .None;
    }

    func updateDifficulty(difficulty: CipherDifficulty) {
        initStyle()

        self.title.text = difficulty.description
    }
}
