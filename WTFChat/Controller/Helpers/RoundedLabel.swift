import UIKit

class RoundedLabel: UILabel {
    var tagObject: AnyObject?

    private var gradientLayer: CAGradientLayer?
    private var newLabelView: RoundedLabel?

    override public var text: String? {
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

    private func initStyle() {
        layer.masksToBounds = false
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.mainScreen().scale
    }

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

    func addGradientToLabel(gradient: [CGColor]) {
        if let existsingGradient = gradientLayer {
            existsingGradient.colors = gradient
            return
        }

        let newLabel = RoundedLabel()
        newLabel.frame = self.frame
        newLabel.frame.origin = CGPointZero
        newLabel.bounds = self.bounds

        newLabel.text = self.text
        newLabel.textColor = self.textColor
        newLabel.font = self.font
        newLabel.numberOfLines = self.numberOfLines
        //newLabel.translatesAutoresizingMaskIntoConstraints = self.translatesAutoresizingMaskIntoConstraints

        gradientLayer = self.addGradient(gradient)
        newLabelView = newLabel
        self.addSubview(newLabel)

        //addSelfContraintsToSubview(newLabel)
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