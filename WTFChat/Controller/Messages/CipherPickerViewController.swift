//
//  CipherPickerViewController.swift
//  WTFChat
//
//  Created by Artem Chuzhmarov on 06/10/15.
//  Copyright © 2015 Artem Chuzhmarov. All rights reserved.
//

import UIKit

protocol CipherPickedComputer {
    func cipherPicked(type: CipherType, difficulty: CipherDifficulty)
}

class CipherPickerViewController: UIPickerView, UIPickerViewDataSource, UIPickerViewDelegate {
    let cipherTypes = CipherFactory.getAllTypes()
    let cipherDificulties = CipherFactory.getAllDifficulties()
    
    var cipherType = CipherType.RightCutter
    var cipherDifficulty = CipherDifficulty.Normal

    var cipherPickedComputer: CipherPickedComputer?
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if (component == 0) {
            return cipherTypes.count
        } else {
            return cipherDificulties.count
        }
    }
    
    func pickerView(pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusingView view: UIView?) -> UIView {
        
        var titleData = ""
        
        if (component == 0) {
            titleData = cipherTypes[row].description
        } else {
            titleData = cipherDificulties[row].description
        }
        
        let myTitle = NSAttributedString(string: titleData, attributes: [NSFontAttributeName:UIFont(name: "Verdana", size: 18.0)!])
        
        let pickerLabel = UILabel()
        pickerLabel.textAlignment = NSTextAlignment.Center
        pickerLabel.attributedText = myTitle
        
        return pickerLabel
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let type = cipherTypes[self.selectedRowInComponent(0)]
        let difficulty = cipherDificulties[self.selectedRowInComponent(1)]

        cipherPickedComputer?.cipherPicked(type, difficulty: difficulty)
    }
    
    func updateCipher(type: CipherType, difficulty: CipherDifficulty) {
        self.cipherType = type
        self.cipherDifficulty = difficulty
        
        self.selectRow(cipherType.rawValue, inComponent: 0, animated: true)
        self.selectRow(cipherDifficulty.rawValue, inComponent: 1, animated: true)
    }
}
