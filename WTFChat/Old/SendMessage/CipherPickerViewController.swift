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
    private let cipherTypes = CipherType.getAll()
    private let cipherDifficulties = CipherDifficulty.getAll()

    private var cipherType = CipherType.RightCutter
    private var cipherDifficulty = CipherDifficulty.Normal

    var cipherPickedComputer: CipherPickedComputer?
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if (component == 0) {
            return cipherTypes.count
        } else {
            return cipherDifficulties.count
        }
    }
    
    func pickerView(pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusingView view: UIView?) -> UIView {
        
        var titleData = ""
        
        if (component == 0) {
            titleData = cipherTypes[row].description
        } else {
            titleData = cipherDifficulties[row].description
        }
        
        let myTitle = NSAttributedString(string: titleData, attributes: [NSFontAttributeName:UIFont.init(name: "Verdana", size: 18.0)!])
        
        let pickerLabel = UILabel()
        pickerLabel.textAlignment = NSTextAlignment.Center
        pickerLabel.attributedText = myTitle
        
        return pickerLabel
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let type = cipherTypes[self.selectedRowInComponent(0)]
        let difficulty = cipherDifficulties[self.selectedRowInComponent(1)]

        cipherPickedComputer?.cipherPicked(type, difficulty: difficulty)
    }
    
    func updateCipher(type: CipherType, difficulty: CipherDifficulty) {
        self.cipherType = type
        self.cipherDifficulty = difficulty
        
        self.selectRow(cipherType.rawValue, inComponent: 0, animated: true)
        self.selectRow(cipherDifficulty.rawValue, inComponent: 1, animated: true)
    }
}
