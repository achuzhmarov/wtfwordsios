import Foundation

class TopArrowImage: ArrowImage {
    override func getArrowPath(size: CGFloat) -> UIBezierPath {
        return UIBezierPath.topArrow(size)
    }
}

class RightArrowImage: ArrowImage {
    override func getArrowPath(size: CGFloat) -> UIBezierPath {
        return UIBezierPath.rightArrow(size)
    }
}

class LeftArrowImage: ArrowImage {
    override func getArrowPath(size: CGFloat) -> UIBezierPath {
        return UIBezierPath.leftArrow(size)
    }
}

class ArrowImage: UIImageView {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        image = createArrowImage(Gradient.Background, backgroundGradient: Gradient.Ciphered)
    }

    private func createArrowImage(arrowGradient: [CGColor], backgroundGradient: [CGColor]) -> UIImage {
        let size = bounds.width

        UIGraphicsBeginImageContextWithOptions(CGSize(width: size, height: size), false, 0.0)
        let context = UIGraphicsGetCurrentContext()

        CGContextSaveGState(context)

        addGradient(context!,
                clipPath: getCirclePath(size),
                size: size,
                colors: backgroundGradient
        )

        addGradient(context!,
                clipPath: getArrowPath(size),
                size: size,
                colors: arrowGradient
        )

        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return image
    }

    private func addGradient(context: CGContext, clipPath: UIBezierPath, size: CGFloat, colors: [CGColor]) {
        clipPath.addClip()
        let gradient = CGGradientCreateWithColors(CGColorSpaceCreateDeviceRGB(), colors, nil)
        CGContextDrawLinearGradient(context, gradient, CGPointMake(0, 0), CGPointMake(size, size), [])
    }

    func getCirclePath(size: CGFloat) -> UIBezierPath {
        return UIBezierPath.circle(size)
    }

    func getArrowPath(size: CGFloat) -> UIBezierPath {
        fatalError("This method must be overridden")
    }
}
