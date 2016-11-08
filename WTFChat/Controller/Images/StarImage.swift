import UIKit

class StarImageCache {
    var cache = [CipherDifficulty: [CGFloat: UIImage]]()

    init() {
        for difficulty in CipherDifficulty.getAll() {
            cache[difficulty] = [CGFloat: UIImage]()
        }
    }

    func getImage(_ difficulty: CipherDifficulty, progress: CGFloat) -> UIImage? {
        let difficultyCache = cache[difficulty]!

        if let cachedImage = difficultyCache[progress] {
            return cachedImage
        }

        return nil
    }

    func addImage(_ difficulty: CipherDifficulty, progress: CGFloat, image: UIImage) {
        cache[difficulty]![progress] = image
    }
}

class StarImage: UIImageView {
    fileprivate static var cache = StarImageCache()

    func updateStarImage(_ difficulty: CipherDifficulty, progress: Float) {
        let gradientProgress = calculateGradientProgress(progress)

        if let cachedImage = StarImage.cache.getImage(difficulty, progress: gradientProgress) {
            image = cachedImage
        } else {
            let starGradient = Gradient.getStarGradientByDifficulty(difficulty)
            let borderColor = Color.getBorderColorByDifficulty(difficulty)
            image = createStarImage(gradientProgress, starGradient: starGradient, borderColor: borderColor)
            StarImage.cache.addImage(difficulty, progress: gradientProgress, image: image!)
        }
    }

    fileprivate func createStarImage(_ gradientProgress: CGFloat, starGradient: [CGColor], borderColor: UIColor) -> UIImage {
        let size = CGSize(width: bounds.width, height: bounds.height)

        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        let context = UIGraphicsGetCurrentContext()

        //Add Shadow
        let shadow:UIColor = UIColor.black.withAlphaComponent(0.80)
        let shadowOffset = CGSize(width: 1.0, height: 1.0)
        let shadowBlurRadius: CGFloat = size.height / 10

        context?.setShadow(offset: shadowOffset,
                blur: shadowBlurRadius,
                color: shadow.cgColor)

        context?.beginTransparencyLayer(auxiliaryInfo: nil)

        let xCenter = CGFloat(size.width/2);
        let yCenter = CGFloat(size.height/2);

        let w = CGFloat(size.width - 4);
        let r = w / 2.0;
        let flip = CGFloat(-1.0);

        let theta = CGFloat(2.0 * M_PI * (2.0 / 5.0));

        let starPath = UIBezierPath()
        starPath.move(to: CGPoint(x: xCenter, y: r * flip + yCenter))

        for i in 1..<5 {
            let x = r * sin(CGFloat(i) * theta);
            let y = r * cos(CGFloat(i) * theta);
            starPath.addLine(to: CGPoint(x: x + xCenter, y: y * flip + yCenter))
        }

        starPath.close()

        borderColor.setStroke()
        starPath.lineWidth = 1
        starPath.stroke()

        //Gradient

        context?.saveGState()
        starPath.addClip()

        let firstColorLocation = 1 - gradientProgress
        let secondColorLocation = firstColorLocation + (gradientProgress / 2) + 0.01

        let gradient = CGGradient(
            colorsSpace: CGColorSpaceCreateDeviceRGB(),
                colors: starGradient as CFArray,

                locations: [
                    firstColorLocation,
                    secondColorLocation,
                    1
                ]
        )

        context?.drawLinearGradient(gradient!,
            start: CGPoint(x: 0, y: 0),
            end: CGPoint(x: size.width, y: size.height),
            options: []
        )

        context?.restoreGState()

        context?.endTransparencyLayer()

        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return image!
    }

    fileprivate static let gradientProgress: [CGFloat] = [0.1, 0.4, 0.45, 0.5, 0.55, 0.6, 0.65, 0.7, 0.75, 0.8, 1.0]

    fileprivate func calculateGradientProgress(_ progress: Float) -> CGFloat {
        let gradientIndex = Int(progress * 10)

        return StarImage.gradientProgress[gradientIndex]
    }
}
