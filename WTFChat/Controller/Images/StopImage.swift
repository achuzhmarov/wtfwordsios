import Foundation

class StopImage: UIImageView {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        image = createStopImage(Gradient.Background, backgroundGradient: Gradient.Failed)
    }

    private func createStopImage(stopGradient: [CGColor], backgroundGradient: [CGColor]) -> UIImage {
        let size = bounds.width

        UIGraphicsBeginImageContextWithOptions(CGSize(width: size, height: size), false, 0.0)
        let context = UIGraphicsGetCurrentContext()

        CGContextSaveGState(context)

        let backgroundPath = getBackPath(size)

        addGradient(context!,
                clipPath: backgroundPath,
                size: size,
                colors: backgroundGradient
        )

        UIColor.blackColor().setStroke()
        backgroundPath.lineWidth = 2
        backgroundPath.stroke()

        addGradient(context!,
                clipPath: getStopPath(size),
                size: size,
                colors: stopGradient
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

    private func getBackPath(size: CGFloat) -> UIBezierPath {
        return UIBezierPath.roundedRect(size)
    }

    private func getStopPath(size: CGFloat) -> UIBezierPath {
        let padding = size * 0.28
        let stopSize = size - 2 * padding

        let stopRect = CGRectMake(padding, padding, stopSize, stopSize)

        return UIBezierPath(rect: stopRect)
    }
}