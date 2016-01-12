//
//  CustomOperators.swift
//  WTFChat
//
//  Created by Artem Chuzhmarov on 12/01/16.
//  Copyright © 2016 Artem Chuzhmarov. All rights reserved.
//

import Foundation

func intPow(radix: Int, power: Int) -> Int {
    return Int(pow(Double(radix), Double(power)))
}

func connectionErrorDescription() -> String {
    return "Internet connection problem"
}

func isValidEmail(testStr:String) -> Bool {
    let emailRegEx = "^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$"
    
    let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
    return emailTest.evaluateWithObject(testStr)
}

func configureTitleView(title: String, navigationItem: UINavigationItem) {
    //let titleLabel = UILabel(frame: self.navigationController!.navigationBar.frame)
    let titleLabel = UILabel()
    titleLabel.textAlignment = .Center
    titleLabel.font = UIFont.boldSystemFontOfSize(17.0)
    titleLabel.text = title
    navigationItem.titleView = titleLabel
    titleLabel.sizeToFit()
    titleLabel.adjustsFontSizeToFitWidth = true
}