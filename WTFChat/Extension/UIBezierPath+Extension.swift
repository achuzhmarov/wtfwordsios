import Foundation

extension UIBezierPath {
    fileprivate static let TAIL_WIDTH_SCALE: CGFloat = 1 / 3
    fileprivate static let HEAD_WIDTH_SCALE: CGFloat = 1 / 1.3
    fileprivate static let HEAD_LENGTH_SCALE: CGFloat = 1 / 2
    fileprivate static let END_PADDING_SCALE: CGFloat = 1 / 7
    fileprivate static let START_PADDING_SCALE: CGFloat = END_PADDING_SCALE * 1.3

    class func arrow(from start: CGPoint, to end: CGPoint, tailWidth: CGFloat, headWidth: CGFloat, headLength: CGFloat) -> UIBezierPath {
        let length = hypot(end.x - start.x, end.y - start.y)
        let tailLength = length - headLength

        func p(_ x: CGFloat, _ y: CGFloat) -> CGPoint { return CGPoint(x: x, y: y) }
        var points: [CGPoint] = [
                p(0, tailWidth / 2),
                p(tailLength, tailWidth / 2),
                p(tailLength, headWidth / 2),
                p(length, 0),
                p(tailLength, -headWidth / 2),
                p(tailLength, -tailWidth / 2),
                p(0, -tailWidth / 2)
        ]

        let cosine = (end.x - start.x) / length
        let sine = (end.y - start.y) / length
        var transform = CGAffineTransform(a: cosine, b: sine, c: -sine, d: cosine, tx: start.x, ty: start.y)

        let path = CGMutablePath()
        CGPathAddLines(path, &transform, &points, points.count)
        path.closeSubpath()

        return UIBezierPath(cgPath: path)
    }

    class func arrow(_ size: CGFloat, from start: CGPoint, to end: CGPoint) -> UIBezierPath {
        return UIBezierPath.arrow(
        from: start,
                to: end,
                tailWidth: size * TAIL_WIDTH_SCALE,
                headWidth: size * HEAD_WIDTH_SCALE,
                headLength: size * HEAD_LENGTH_SCALE
        )
    }

    class func topArrow(_ size: CGFloat) -> UIBezierPath {
        let startPadding = size * START_PADDING_SCALE
        let endPadding = size * END_PADDING_SCALE

        let startPoint = CGPoint(x: size/2, y: size - startPadding)
        let endPoint = CGPoint(x: size/2, y: endPadding)

        return UIBezierPath.arrow(size - startPadding - endPadding, from: startPoint, to: endPoint)
    }

    class func bottomArrow(_ size: CGFloat) -> UIBezierPath {
        let startPadding = size * START_PADDING_SCALE
        let endPadding = size * END_PADDING_SCALE

        let startPoint = CGPoint(x: size/2, y: startPadding)
        let endPoint = CGPoint(x: size/2, y: size - endPadding)

        return UIBezierPath.arrow(size - startPadding - endPadding, from: startPoint, to: endPoint)
    }

    class func leftArrow(_ size: CGFloat) -> UIBezierPath {
        let startPadding = size * START_PADDING_SCALE
        let endPadding = size * END_PADDING_SCALE

        let startPoint = CGPoint(x: size - startPadding, y: size/2)
        let endPoint = CGPoint(x: endPadding, y: size/2)

        return UIBezierPath.arrow(size - startPadding - endPadding, from: startPoint, to: endPoint)
    }

    class func rightArrow(_ size: CGFloat) -> UIBezierPath {
        let startPadding = size * START_PADDING_SCALE
        let endPadding = size * END_PADDING_SCALE

        let startPoint = CGPoint(x: startPadding, y: size/2)
        let endPoint = CGPoint(x: size - endPadding, y: size/2)


        return UIBezierPath.arrow(size - startPadding - endPadding, from: startPoint, to: endPoint)
    }

    class func circle(_ size: CGFloat) -> UIBezierPath {
        return UIBezierPath(
        arcCenter: CGPoint(x: size / 2, y: size / 2),
                radius: CGFloat(size / 2),
                startAngle: CGFloat(0),
                endAngle:CGFloat(M_PI * 2),
                clockwise: true
        )
    }

    class func roundedRect(_ size: CGFloat) -> UIBezierPath {
        let rect = CGRect(x: 0, y: 0, width: size, height: size)
        return UIBezierPath(roundedRect: rect, cornerRadius: 8.0)
    }
}
