import Foundation

class TopArrowImage: ArrowImage {
    override func getArrowPath(_ size: CGFloat) -> UIBezierPath {
        return UIBezierPath.topArrow(size)
    }
}

class BottomArrowImage: ArrowImage {
    override func getArrowPath(_ size: CGFloat) -> UIBezierPath {
        return UIBezierPath.bottomArrow(size)
    }
}

class RightArrowImage: ArrowImage {
    override func getArrowPath(_ size: CGFloat) -> UIBezierPath {
        return UIBezierPath.rightArrow(size)
    }
}

class LeftArrowImage: ArrowImage {
    override func getArrowPath(_ size: CGFloat) -> UIBezierPath {
        return UIBezierPath.leftArrow(size)
    }
}

class ArrowImage: UIImageView {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        image = createArrowImage(Gradient.Background, backgroundGradient: Gradient.Ciphered)
    }

    fileprivate func createArrowImage(_ arrowGradient: [CGColor], backgroundGradient: [CGColor]) -> UIImage {
        let size = bounds.width

        UIGraphicsBeginImageContextWithOptions(CGSize(width: size, height: size), false, 0.0)
        let context = UIGraphicsGetCurrentContext()

        context?.saveGState()

        addGradient(context!,
                clipPath: getBackPath(size),
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

        return image!
    }

    fileprivate func addGradient(_ context: CGContext, clipPath: UIBezierPath, size: CGFloat, colors: [CGColor]) {
        clipPath.addClip()
        let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: colors as CFArray, locations: nil)
        context.drawLinearGradient(gradient!, start: CGPoint(x: 0, y: 0), end: CGPoint(x: size, y: size), options: [])
    }

    func getBackPath(_ size: CGFloat) -> UIBezierPath {
        return UIBezierPath.roundedRect(size)
    }

    func getArrowPath(_ size: CGFloat) -> UIBezierPath {
        fatalError("This method must be overridden")
    }
}
