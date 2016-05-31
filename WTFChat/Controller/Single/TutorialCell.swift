//
//  TutorialCell.swift
//  WTFChat
//
//  Created by Artem Chuzhmarov on 16/11/15.
//  Copyright © 2015 Artem Chuzhmarov. All rights reserved.
//

import UIKit

class TutorialCell: UITableViewCell {
    @IBOutlet weak var title: UILabel!
    
    func initStyle() {
        title.adjustsFontSizeToFitWidth = true

        self.selectionStyle = .None;
    }
    
    func updateTitle(title: String) {
        initStyle()

        self.title.text = title
    }
}
