//
// Created by Artem Chuzhmarov on 01/06/16.
// Copyright (c) 2016 Artem Chuzhmarov. All rights reserved.
//

import UIKit

class StarImage: UIImageView {
    //Gold colors
    static let lightGoldColor = UIColor(red: 1.0, green: 0.98, blue: 0.9, alpha: 1.0)
    static let darkGoldColor = UIColor(red: 0.6, green: 0.5, blue: 0.15, alpha: 1.0)
    static let midGoldColor = UIColor(red: 0.86, green: 0.73, blue: 0.3, alpha: 1.0)

    static var cache = [CGFloat: UIImage]()

    func updateStarImage(current: Int, max: Int) {
        let gradientProgress = calculateGradientProgress(current, max: max)

        if let cachedImage = StarImage.cache[gradientProgress] {
            image = cachedImage
        } else {
            image = createStarImage(gradientProgress)
            StarImage.cache[gradientProgress] = image
        }
    }

    private func createStarImage(gradientProgress: CGFloat) -> UIImage {
        print("creating Star Image for gradient \(gradientProgress)")

        let size = CGSize(width: bounds.width, height: bounds.height)

        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        let context = UIGraphicsGetCurrentContext()

        //Add Shadow
        let shadow:UIColor = UIColor.blackColor().colorWithAlphaComponent(0.80)
        let shadowOffset = CGSizeMake(1.0, 1.0)
        let shadowBlurRadius: CGFloat = 4

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

        StarImage.darkGoldColor.setStroke()
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
                    StarImage.lightGoldColor.CGColor,
                    StarImage.midGoldColor.CGColor,
                    StarImage.darkGoldColor.CGColor
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

    private func calculateGradientProgress(current: Int, max: Int) -> CGFloat {
        if (current >= max) {
            return 1.0
        }

        let progress = Float(current) / Float(max)
        let gradientIndex = Int(progress * 10)

        return StarImage.gradientProgress[gradientIndex]
    }
}
