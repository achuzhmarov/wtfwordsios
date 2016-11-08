import Foundation

extension UIView {
    func addLinearGradient(_ colors: [CGColor], size: CGSize? = nil) -> CAGradientLayer {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame.size = size ?? self.frame.size
        gradientLayer.frame.origin = CGPoint.zero
        gradientLayer.cornerRadius = layer.cornerRadius

        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.0)
        gradientLayer.colors = colors

        layer.insertSublayer(gradientLayer, at: 0)

        return gradientLayer
    }

    func addDiagonalGradient(_ colors: [CGColor], size: CGSize? = nil) -> CAGradientLayer {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame.size = size ?? self.frame.size
        gradientLayer.frame.origin = CGPoint.zero
        gradientLayer.cornerRadius = layer.cornerRadius

        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 1.0)
        gradientLayer.colors = colors

        layer.insertSublayer(gradientLayer, at: 0)

        return gradientLayer
    }

    func addSelfContraintsToSubview(_ subView: UIView) {
        let trailing = NSLayoutConstraint(item: subView, attribute: NSLayoutAttribute.trailing, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.trailing, multiplier: 1, constant: 0)
        let leading = NSLayoutConstraint(item: subView, attribute: NSLayoutAttribute.leading, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.leading, multiplier: 1, constant: 0)
        let top = NSLayoutConstraint(item: subView, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.top, multiplier: 1, constant: 0)
        let bottom = NSLayoutConstraint(item: subView, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.bottom, multiplier: 1, constant: 0)

        self.addConstraint(trailing)
        self.addConstraint(leading)
        self.addConstraint(top)
        self.addConstraint(bottom)
    }
}
