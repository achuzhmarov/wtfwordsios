//
//  WordLabel.swift
//  WTFChat
//
//  Created by Artem Chuzhmarov on 09/09/15.
//  Copyright (c) 2015 Artem Chuzhmarov. All rights reserved.
//

import UIKit

class RoundedLabel: UILabel {
    var container: WordLabelContainer?
    
    func getWidth() -> CGFloat {
        return bounds.width // + edgeInsets.left + edgeInsets.right
    }
    
    var edgeInsets = UIEdgeInsets(top: 5, left: 10, bottom: 7, right: 10)
    
    override func textRectForBounds(bounds: CGRect, limitedToNumberOfLines numberOfLines: Int) -> CGRect {
        var rect = super.textRectForBounds(bounds, limitedToNumberOfLines: numberOfLines)
        
        if let text = text {
            let estimatedWidth = CGRectGetWidth(rect)
            let estimatedHeight = CGFloat.max
            let calculatedFrame = NSString(string: text).boundingRectWithSize(CGSize(width: estimatedWidth, height: estimatedHeight), options: .UsesLineFragmentOrigin, attributes: [NSFontAttributeName: font], context: nil)
            
            //let calculatedWidth = ceil(CGRectGetWidth(calculatedFrame))
            let calculatedHeight = ceil(CGRectGetHeight(calculatedFrame))
            let finalHeight = (calculatedHeight + edgeInsets.top + edgeInsets.bottom)
            let finalWidth = (estimatedWidth + edgeInsets.left + edgeInsets.right)
            
            rect.size = CGSize(width: finalWidth, height: finalHeight)
        }
        
        return rect
    }
    
    override func drawTextInRect(rect: CGRect) {
        let textRect = UIEdgeInsetsInsetRect(rect, edgeInsets)
        super.drawTextInRect(textRect)
    }
    
    func setMargins(top: CGFloat, left: CGFloat, bottom: CGFloat, right: CGFloat) {
        edgeInsets = UIEdgeInsets(top: top, left: left, bottom: bottom, right: right)
    }
}