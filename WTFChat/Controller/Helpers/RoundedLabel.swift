import UIKit

class RoundedLabel: UILabel {
    var tagObject: AnyObject?

    fileprivate var gradientLayer: CAGradientLayer?
    fileprivate var newLabelView: RoundedLabel?

    override var text: String? {
        didSet {
            newLabelView?.text = self.text
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        initStyle()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initStyle()
    }

    override func layoutSubviews() {
        gradientLayer?.frame = self.bounds
        newLabelView?.frame = self.bounds
    }

    fileprivate func initStyle() {
        layer.masksToBounds = false
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.main.scale
    }

    func getWidth() -> CGFloat {
        return bounds.width
    }
    
    var edgeInsets = UIEdgeInsets(top: 5, left: 10, bottom: 7, right: 10)
    
    override func textRect(forBounds bounds: CGRect, limitedToNumberOfLines numberOfLines: Int) -> CGRect {
        var rect = edgeInsets.apply(bounds)
        rect = super.textRect(forBounds: rect, limitedToNumberOfLines: numberOfLines)
        return edgeInsets.inverse.apply(rect)
    }
    
    override func drawText(in rect: CGRect) {
        super.drawText(in: edgeInsets.apply(rect))
    }
    
    func setMargins(_ top: CGFloat, left: CGFloat, bottom: CGFloat, right: CGFloat) {
        edgeInsets = UIEdgeInsets(top: top, left: left, bottom: bottom, right: right)
    }

    func addGradientToLabel(_ gradient: [CGColor]) {
        if let existsingGradient = gradientLayer {
            existsingGradient.colors = gradient
            return
        }

        let newLabel = RoundedLabel()
        newLabel.frame = self.frame
        newLabel.frame.origin = CGPoint.zero
        newLabel.bounds = self.bounds

        newLabel.text = self.text
        newLabel.textColor = self.textColor
        newLabel.font = self.font
        newLabel.numberOfLines = self.numberOfLines

        gradientLayer = self.addDiagonalGradient(gradient)
        newLabelView = newLabel

        //self.insertSubview(newLabel, atIndex: 0)
        self.addSubview(newLabel)
    }
}

extension UIEdgeInsets {
    var inverse : UIEdgeInsets {
        return UIEdgeInsets(top: -top, left: -left, bottom: -bottom, right: -right)
    }
    func apply(_ rect: CGRect) -> CGRect {
        return UIEdgeInsetsInsetRect(rect, self)
    }
}
