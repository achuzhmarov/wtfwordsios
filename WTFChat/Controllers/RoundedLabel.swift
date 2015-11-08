//
//  WordLabel.swift
//  WTFChat
//
//  Created by Artem Chuzhmarov on 09/09/15.
//  Copyright (c) 2015 Artem Chuzhmarov. All rights reserved.
//

import UIKit

class RoundedLabel: UILabel {
    var tagObject: AnyObject?
    
    func getWidth() -> CGFloat {
        return bounds.width
    }
    
    var edgeInsets = UIEdgeInsets(top: 5, left: 10, bottom: 7, right: 10)
    
    override func textRectForBounds(bounds: CGRect, limitedToNumberOfLines numberOfLines: Int) -> CGRect {
        var rect = edgeInsets.apply(bounds)
        rect = super.textRectForBounds(rect, limitedToNumberOfLines: numberOfLines)
        return edgeInsets.inverse.apply(rect)
    }
    
    override func drawTextInRect(rect: CGRect) {
        super.drawTextInRect(edgeInsets.apply(rect))
    }
    
    func setMargins(top: CGFloat, left: CGFloat, bottom: CGFloat, right: CGFloat) {
        edgeInsets = UIEdgeInsets(top: top, left: left, bottom: bottom, right: right)
    }
}

extension UIEdgeInsets {
    var inverse : UIEdgeInsets {
        return UIEdgeInsets(top: -top, left: -left, bottom: -bottom, right: -right)
    }
    func apply(rect: CGRect) -> CGRect {
        return UIEdgeInsetsInsetRect(rect, self)
    }
}