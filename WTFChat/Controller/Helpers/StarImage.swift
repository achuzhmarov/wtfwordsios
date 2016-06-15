import UIKit

class StarGradient {
    let light: UIColor
    let mid: UIColor
    let dark: UIColor

    init(light: UIColor, mid: UIColor, dark: UIColor) {
        self.light = light
        self.mid = mid
        self.dark = dark
    }

    static let EasyGrad = StarGradient(light: Color.EasyLight, mid: Color.EasyMid, dark: Color.EasyDark)
    static let NormalGrad = StarGradient(light: Color.NormalLight, mid: Color.NormalMid, dark: Color.NormalDark)
    static let HardGrad = StarGradient(light: Color.HardLight, mid: Color.HardMid, dark: Color.HardDark)
}

class StarImageCache {
    var cache = [CipherDifficulty: [CGFloat: UIImage]]()

    init() {
        for difficulty in CipherDifficulty.getAll() {
            cache[difficulty] = [CGFloat: UIImage]()
        }
    }

    func getImage(difficulty: CipherDifficulty, progress: CGFloat) -> UIImage? {
        let difficultyCache = cache[difficulty]!

        if let cachedImage = difficultyCache[progress] {
            return cachedImage
        }

        return nil
    }

    func addImage(difficulty: CipherDifficulty, progress: CGFloat, image: UIImage) {
        cache[difficulty]![progress] = image
    }
}

class StarImage: UIImageView {
    private static var cache = StarImageCache()

    func updateStarImage(difficulty: CipherDifficulty, progress: Float) {
        let gradientProgress = calculateGradientProgress(progress)

        if let cachedImage = StarImage.cache.getImage(difficulty, progress: gradientProgress) {
            image = cachedImage
        } else {
            let starGradient = getStarGradient(difficulty)
            image = createStarImage(gradientProgress, starGradient: starGradient)
            StarImage.cache.addImage(difficulty, progress: gradientProgress, image: image!)
        }
    }

    private func createStarImage(gradientProgress: CGFloat, starGradient: StarGradient) -> UIImage {
        print("creating Star Image for gradient \(gradientProgress)")

        let size = CGSize(width: bounds.width, height: bounds.height)

        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        let context = UIGraphicsGetCurrentContext()

        //Add Shadow
        let shadow:UIColor = UIColor.blackColor().colorWithAlphaComponent(0.80)
        let shadowOffset = CGSizeMake(1.0, 1.0)
        let shadowBlurRadius: CGFloat = size.height / 10

        CGContextSetShadowWithColor(context,
                shadowOffset,
                shadowBlurRadius,
                shadow.CGColor)

        CGContextBeginTransparencyLayer(context, nil)

        let xCenter = CGFloat(size.width/2);
        let yCenter = CGFloat(size.height/2);

        let w = CGFloat(size.width - 4);
        let r = w / 2.0;
        let flip = CGFloat(-1.0);

        let theta = CGFloat(2.0 * M_PI * (2.0 / 5.0));

        let starPath = UIBezierPath()
        starPath.moveToPoint(CGPointMake(xCenter, r * flip + yCenter))

        for i in 1..<5 {
            let x = r * sin(CGFloat(i) * theta);
            let y = r * cos(CGFloat(i) * theta);
            starPath.addLineToPoint(CGPointMake(x + xCenter, y * flip + yCenter))
        }

        starPath.closePath()

        starGradient.dark.setStroke()
        starPath.lineWidth = 1
        starPath.stroke()

        //Gradient

        CGContextSaveGState(context)
        starPath.addClip()

        let firstColorLocation = 1 - gradientProgress
        let secondColorLocation = firstColorLocation + (gradientProgress / 2) + 0.01

        let gradient = CGGradientCreateWithColors(
            CGColorSpaceCreateDeviceRGB(),
                [
                    starGradient.light.CGColor,
                    starGradient.mid.CGColor,
                    starGradient.dark.CGColor
                ],

                [
                    firstColorLocation,
                    secondColorLocation,
                    1
                ]
        )

        CGContextDrawLinearGradient(context,
            gradient,
            CGPointMake(0, 0),
            CGPointMake(size.width, size.height),
            []
        )

        CGContextRestoreGState(context)

        CGContextEndTransparencyLayer(context)

        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return image
    }

    private static let gradientProgress: [CGFloat] = [0.1, 0.3, 0.35, 0.4, 0.45, 0.5, 0.55, 0.6, 0.65, 0.7]

    private func calculateGradientProgress(progress: Float) -> CGFloat {
        let gradientIndex = Int(progress * 10)

        return StarImage.gradientProgress[gradientIndex]
    }

    private func getStarGradient(difficulty: CipherDifficulty) -> StarGradient {
        switch difficulty {
            case .Easy:
                return StarGradient.EasyGrad
            case .Normal:
                return StarGradient.NormalGrad
            case .Hard:
                return StarGradient.HardGrad
        }
    }
}
