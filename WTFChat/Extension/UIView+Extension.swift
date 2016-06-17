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
}