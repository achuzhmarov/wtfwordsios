import Foundation

class WordLabelContainer {
    var label = RoundedLabel()
    var fontSize: CGFloat
    var isHidedText: Bool

    var originalWord: Word

    var word: Word {
        didSet {
            updateLabel()
        }
    }
    
    var useCipherText = false
    var selfAuthor = false
    
    var wasAddedToCell = false
    
    init (word: Word, useCipherText: Bool, selfAuthor: Bool, isHidedText: Bool, fontSize: CGFloat) {
        self.originalWord = word
        self.word = Word(word: word)
        self.useCipherText = useCipherText
        self.selfAuthor = selfAuthor
        self.isHidedText = isHidedText
        self.fontSize = fontSize

        updateLabel()
    }
    
    func updateLabel() {
        label.text = getLabelText()
        
        label.textColor = UIColor.whiteColor()
        label.font = UIFont.init(name: label.font.fontName, size: fontSize)

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
        //label.hidden = true
        
        //to use taps for suggestions
        label.userInteractionEnabled = true
        
        label.sizeToFit()
        
        label.tagObject = self
    }

    private func getLabelText() -> String {
        if (isHidedText) {
            return word.getHidedText()
        }

        if (useCipherText) {
            if (word.type != WordType.Ignore) {
                return word.getCipheredText()
            } else {
                return word.getTextForDecipher()
            }
        }

        if (selfAuthor) {
            return word.getClearText()
        }

        return word.getTextForDecipher()
    }
    
    func getWidth() -> CGFloat {
        return label.getWidth()
    }
    
    func getWidthWithMargin() -> CGFloat {
        return label.getWidth() + labelHorizontalMargin
    }

    /*func show() {
        label.hidden = false

        if (animated) {
            label.alpha = 0

            UIView.animateWithDuration(0.3, delay: 0,
                    options: [], animations: {
                self.label.alpha = 1
            }, completion: nil)
        } else {
            label.alpha = 1
        }
    }*/
    
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