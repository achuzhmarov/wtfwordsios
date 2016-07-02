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
            } else {
                label.addGradientToLabel(Gradient.Ciphered)
            }
        case .Ignore:
            label.addGradientToLabel(Gradient.Ignored)
        case .Failed:
            label.addGradientToLabel(Gradient.Failed)
        default:
            label.addGradientToLabel(Gradient.Success)
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
                self.label.addGradientToLabel(Gradient.Try)
            }, completion: animateWarningBack)
    }

    private func animateWarningBack(completed: Bool) {
        UIView.animateWithDuration(0.4, delay: 0,
                options: [], animations: {
            self.label.center.y += 3
        }, completion: nil)
    }
    
    func animateError() {
        UIView.animateWithDuration(0.3, delay: 0,
            options: [], animations: {
                self.label.center.y -= 3
                self.label.addGradientToLabel(Gradient.Failed)
            }, completion: animateErrorBack)
    }

    private func animateErrorBack(completed: Bool) {
        UIView.animateWithDuration(0.4, delay: 0,
                options: [], animations: {
            self.label.center.y += 3

            if (self.word.wasCloseTry) {
                self.label.addGradientToLabel(Gradient.Try)
            } else {
                self.label.addGradientToLabel(Gradient.Ciphered)
            }
        }, completion: nil)
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