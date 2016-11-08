//
//  CipherPickerViewController.swift
//  WTFChat
//
//  Created by Artem Chuzhmarov on 06/10/15.
//  Copyright © 2015 Artem Chuzhmarov. All rights reserved.
//

import UIKit

protocol CipherPickedComputer {
    func cipherPicked(_ type: CipherType, difficulty: CipherDifficulty)
}

class CipherPickerViewController: UIPickerView, UIPickerViewDataSource, UIPickerViewDelegate {
    fileprivate let cipherTypes = CipherType.getAll()
    fileprivate let cipherDifficulties = CipherDifficulty.getAll()

    fileprivate var cipherType = CipherType.rightCutter
    fileprivate var cipherDifficulty = CipherDifficulty.normal

    var cipherPickedComputer: CipherPickedComputer?
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if (component == 0) {
            return cipherTypes.count
        } else {
            return cipherDifficulties.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        
        var titleData = ""
        
        if (component == 0) {
            titleData = cipherTypes[row].description
        } else {
            titleData = cipherDifficulties[row].description
        }
        
        let myTitle = NSAttributedString(string: titleData, attributes: [NSFontAttributeName:UIFont.init(name: "Verdana", size: 18.0)!])
        
        let pickerLabel = UILabel()
        pickerLabel.textAlignment = NSTextAlignment.center
        pickerLabel.attributedText = myTitle
        
        return pickerLabel
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let type = cipherTypes[self.selectedRow(inComponent: 0)]
        let difficulty = cipherDifficulties[self.selectedRow(inComponent: 1)]

        cipherPickedComputer?.cipherPicked(type, difficulty: difficulty)
    }
    
    func updateCipher(_ type: CipherType, difficulty: CipherDifficulty) {
        self.cipherType = type
        self.cipherDifficulty = difficulty
        
        self.selectRow(cipherType.rawValue, inComponent: 0, animated: true)
        self.selectRow(cipherDifficulty.rawValue, inComponent: 1, animated: true)
    }
}
