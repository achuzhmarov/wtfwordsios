//
//  WordLabelContainer.swift
//  WTFChat
//
//  Created by Artem Chuzhmarov on 09/09/15.
//  Copyright (c) 2015 Artem Chuzhmarov. All rights reserved.
//

import Foundation

class WordLabelContainer {
    var label = RoundedLabel()
    
    var originalWord: Word

    var word: Word {
        didSet {
            updateLabel()
        }
    }
    
    var useCipherText = false
    var selfAuthor = false
    
    var wasAddedToCell = false
    
    init (word: Word, useCipherText: Bool = false, selfAuthor: Bool = false) {
        self.originalWord = word
        self.word = Word(word: word)
        self.useCipherText = useCipherText
        self.selfAuthor = selfAuthor
        updateLabel()
    }
    
    func updateLabel() {
        if (useCipherText) {
            if (word.type != WordType.Ignore) {
                label.text = word.getCipheredText()
            } else {
                label.text = word.getTextForDecipher()
            }
        } else if (selfAuthor) {
            label.text = word.getClearText()
        } else {
            label.text = word.getTextForDecipher()
        }
        
        label.textColor = UIColor.whiteColor()
        label.font = UIFont(name: label.font.fontName, size: 17)

        label.layer.cornerRadius = 8.0

        switch word.type {
        case .New:
            if (word.wasCloseTry) {
                label.addGradientToLabel(Gradient.Try)
                //label.layer.backgroundColor = Color.Try.CGColor
            } else {
                label.addGradientToLabel(Gradient.Ciphered)
                //label.layer.backgroundColor = Color.Ciphered.CGColor
            }
        case .Ignore:
            label.addGradientToLabel(Gradient.Ignored)
            //label.layer.backgroundColor = Color.Ignore.CGColor
            //label.textColor = UIColor.blackColor()
        case .Failed:
            label.addGradientToLabel(Gradient.Failed)
            //label.layer.backgroundColor = Color.Failed.CGColor
        default:
            label.addGradientToLabel(Gradient.Success)
            //label.layer.backgroundColor = Color.Success.CGColor
        }
        
        label.translatesAutoresizingMaskIntoConstraints = false
        
        label.numberOfLines = 0
        label.hidden = true
        
        //to use taps for suggestions
        label.userInteractionEnabled = true
        
        label.sizeToFit()
        
        label.tagObject = self
    }
    
    func getWidth() -> CGFloat {
        return label.getWidth()
    }
    
    func getWidthWithMargin() -> CGFloat {
        return label.getWidth() + labelHorizontalMargin
    }
    
    func show() {
        label.alpha = 0
        label.hidden = false
        
        UIView.animateWithDuration(0.5, delay: 0,
            options: [], animations: {
                self.label.alpha = 1
            }, completion: nil)
    }
    
    func animateWarning() {
        UIView.animateWithDuration(0.3, delay: 0,
            options: [], animations: {
                self.label.center.y -= 3
                self.label.addGradient(Gradient.Try)
                //self.label.layer.backgroundColor = Color.Try.CGColor
            }, completion: nil)
        
        UIView.animateWithDuration(0.4, delay: 0.3,
            options: [], animations: {
                self.label.center.y += 3
                //self.label.layer.backgroundColor = CIPHERED_COLOR.CGColor
            }, completion: nil)
    }
    
    func animateError() {
        self.label.addGradient(Gradient.Failed)

        UIView.animateWithDuration(0.3, delay: 0,
            options: [], animations: {
                self.label.center.y -= 3
                //self.label.layer.backgroundColor = Color.Failed.CGColor
            }, completion: nil)
        
        /*UIView.animateWithDuration(0.4, delay: 0.3,
            options: [], animations: {
                self.label.center.y += 3
                
                if (self.word.wasCloseTry) {
                    self.label.addGradientToLabel(Gradient.Try)
                    //self.label.layer.backgroundColor = Color.Try.CGColor
                } else {
                    self.label.addGradientToLabel(Gradient.Ciphered)
                    //self.label.layer.backgroundColor = Color.Ciphered.CGColor
                }
            }, completion: nil)*/
    }
    
    let labelHorizontalMargin = CGFloat(2)
    let labelVerticalMargin = CGFloat(2)
    
    func getNextHorizontalConstraint(wordContainer: WordLabelContainer) -> NSLayoutConstraint {
        return NSLayoutConstraint(item: self.label, attribute: NSLayoutAttribute.Leading, relatedBy: NSLayoutRelation.Equal, toItem: wordContainer.label, attribute: NSLayoutAttribute.Trailing, multiplier: 1, constant: labelHorizontalMargin)
    }
    
    func getFirstHorizontalConstraint(parentView: UIView) -> NSLayoutConstraint {
        return NSLayoutConstraint(item: self.label, attribute: NSLayoutAttribute.Leading, relatedBy: NSLayoutRelation.Equal, toItem: parentView, attribute: NSLayoutAttribute.Leading, multiplier: 1, constant: 0)
    }
    
    func getVerticalConstraint(parentView: UIView) -> NSLayoutConstraint {
        return NSLayoutConstraint(item: self.label, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: parentView, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: 0)
    }
    
    func getFullRowHorizontalConstraint(parentView: UIView) -> NSLayoutConstraint {
        return NSLayoutConstraint(item: self.label, attribute: NSLayoutAttribute.Trailing, relatedBy: NSLayoutRelation.Equal, toItem: parentView, attribute: NSLayoutAttribute.Trailing, multiplier: 1, constant: 0)
    }
}