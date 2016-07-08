import Foundation

extension UIView {
    func addLinearGradient(colors: [CGColor], size: CGSize? = nil) -> CAGradientLayer {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame.size = size ?? self.frame.size
        gradientLayer.frame.origin = CGPointZero
        gradientLayer.cornerRadius = layer.cornerRadius

        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.0)
        gradientLayer.colors = colors

        layer.insertSublayer(gradientLayer, atIndex: 0)

        return gradientLayer
    }

    func addDiagonalGradient(colors: [CGColor], size: CGSize? = nil) -> CAGradientLayer {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame.size = size ?? self.frame.size
        gradientLayer.frame.origin = CGPointZero
        gradientLayer.cornerRadius = layer.cornerRadius

        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 1.0)
        gradientLayer.colors = colors

        layer.insertSublayer(gradientLayer, atIndex: 0)

        return gradientLayer
    }
}