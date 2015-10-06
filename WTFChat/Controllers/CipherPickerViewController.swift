//
//  CipherPickerViewController.swift
//  WTFChat
//
//  Created by Artem Chuzhmarov on 06/10/15.
//  Copyright © 2015 Artem Chuzhmarov. All rights reserved.
//

import UIKit

protocol CipherPickedComputer {
    func cipherPicked(cipherType: CipherType)
}

class CipherPickerViewController: UIPickerView, UIPickerViewDataSource, UIPickerViewDelegate {
    let cipherCategories = CipherFactory.getAllCategories()
    let cipherModes = CipherFactory.getAllModes()
    
    var cipherType = CipherType.HalfWordRoundDown
    var cipherPickedComputer: CipherPickedComputer?
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if (component == 0) {
            return cipherCategories.count
        } else {
            return cipherModes.count
        }
    }

    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if (component == 0) {
            return cipherCategories[row].description
        } else {
            return cipherModes[row].description
        }
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let category = cipherCategories[self.selectedRowInComponent(0)]
        let mode = cipherModes[self.selectedRowInComponent(1)]
        
        let cipherType = CipherFactory.getCipherType(category, mode: mode)
        
        cipherPickedComputer?.cipherPicked(cipherType)
    }
    
    func updateCipherType(cipherType: CipherType) {
        self.cipherType = cipherType
        let (category, mode) = CipherFactory.getCategoryAndMode(cipherType)
        
        self.selectRow(category.rawValue, inComponent: 0, animated: true)
        self.selectRow(mode.rawValue, inComponent: 1, animated: true)
    }
    
    /*func pickerView(pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        let titleData = pickerData[row]
        let myTitle = NSAttributedString(string: titleData, attributes: [NSFontAttributeName:UIFont(name: "Georgia", size: 15.0)!,NSForegroundColorAttributeName:UIColor.blueColor()])
        return myTitle
    }*/
    
    /*func pickerView(pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusingView view: UIView?) -> UIView {
        let pickerLabel = UILabel()
        let titleData = pickerData[row]
        let myTitle = NSAttributedString(string: titleData, attributes: [NSFontAttributeName:UIFont(name: "Georgia", size: 26.0)!,NSForegroundColorAttributeName:UIColor.blackColor()])
        pickerLabel.attributedText = myTitle
        return pickerLabel
    }*/
}
