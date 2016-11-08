import Foundation

class StopImage: UIImageView {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        image = createStopImage(Gradient.Background, backgroundGradient: Gradient.Failed)
    }

    fileprivate func createStopImage(_ stopGradient: [CGColor], backgroundGradient: [CGColor]) -> UIImage {
        let size = bounds.width

        UIGraphicsBeginImageContextWithOptions(CGSize(width: size, height: size), false, 0.0)
        let context = UIGraphicsGetCurrentContext()

        context?.saveGState()

        let backgroundPath = getBackPath(size)

        addGradient(context!,
                clipPath: backgroundPath,
                size: size,
                colors: backgroundGradient
        )

        /*UIColor.blackColor().setStroke()
        backgroundPath.lineWidth = 2
        backgroundPath.stroke()*/

        addGradient(context!,
                clipPath: getStopPath(size),
                size: size,
                colors: stopGradient
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

    fileprivate func getBackPath(_ size: CGFloat) -> UIBezierPath {
        return UIBezierPath.roundedRect(size)
    }

    fileprivate func getStopPath(_ size: CGFloat) -> UIBezierPath {
        let padding = size * 0.28
        let stopSize = size - 2 * padding

        let stopRect = CGRect(x: padding, y: padding, width: stopSize, height: stopSize)

        return UIBezierPath(rect: stopRect)
    }
}
