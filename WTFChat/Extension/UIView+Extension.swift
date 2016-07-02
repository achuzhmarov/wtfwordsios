import Foundation

extension UIView {
    func addGradient(colors: [CGColor]) -> CAGradientLayer {
        let gradientLayer : CAGradientLayer = CAGradientLayer()
        gradientLayer.frame.size = self.frame.size
        gradientLayer.frame.origin = CGPointZero
        gradientLayer.cornerRadius = layer.cornerRadius

        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 1.0)
        gradientLayer.colors = colors

        layer.insertSublayer(gradientLayer, atIndex: 0)

        return gradientLayer
    }

    func addSelfContraintsToSubview(subView: UIView) {
        let trailing = NSLayoutConstraint(item: subView, attribute: NSLayoutAttribute.Trailing, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Trailing, multiplier: 1, constant: 0)
        let leading = NSLayoutConstraint(item: subView, attribute: NSLayoutAttribute.Leading, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Leading, multiplier: 1, constant: 0)
        let top = NSLayoutConstraint(item: subView, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Top, multiplier: 1, constant: 0)
        let bottom = NSLayoutConstraint(item: subView, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: 0)

        self.addConstraint(trailing)
        self.addConstraint(leading)
        self.addConstraint(top)
        self.addConstraint(bottom)

        /*for constraint: NSLayoutConstraint in self.constraints {
            if (constraint.firstAttribute == .Width) {
                let widthConstraint = NSLayoutConstraint(item: subView, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: constraint.constant)
                self.addConstraint(widthConstraint)
            }
        }*/
    }
}