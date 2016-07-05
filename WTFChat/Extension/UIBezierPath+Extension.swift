import Foundation

extension UIBezierPath {
    private static let TAIL_WIDTH_SCALE: CGFloat = 1 / 3
    private static let HEAD_WIDTH_SCALE: CGFloat = 1 / 1.3
    private static let HEAD_LENGTH_SCALE: CGFloat = 1 / 2
    private static let END_PADDING_SCALE: CGFloat = 1 / 7
    private static let START_PADDING_SCALE: CGFloat = END_PADDING_SCALE * 1.3

    class func arrow(from start: CGPoint, to end: CGPoint, tailWidth: CGFloat, headWidth: CGFloat, headLength: CGFloat) -> UIBezierPath {
        let length = hypot(end.x - start.x, end.y - start.y)
        let tailLength = length - headLength

        func p(x: CGFloat, _ y: CGFloat) -> CGPoint { return CGPoint(x: x, y: y) }
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

        let path = CGPathCreateMutable()
        CGPathAddLines(path, &transform, &points, points.count)
        CGPathCloseSubpath(path)

        return UIBezierPath(CGPath: path)
    }

    class func arrow(size: CGFloat, from start: CGPoint, to end: CGPoint) -> UIBezierPath {
        return UIBezierPath.arrow(
        from: start,
                to: end,
                tailWidth: size * TAIL_WIDTH_SCALE,
                headWidth: size * HEAD_WIDTH_SCALE,
                headLength: size * HEAD_LENGTH_SCALE
        )
    }

    class func topArrow(size: CGFloat) -> UIBezierPath {
        let startPadding = size * START_PADDING_SCALE
        let endPadding = size * END_PADDING_SCALE

        let startPoint = CGPointMake(size/2, size - startPadding)
        let endPoint = CGPointMake(size/2, endPadding)

        return UIBezierPath.arrow(size - startPadding - endPadding, from: startPoint, to: endPoint)
    }

    class func leftArrow(size: CGFloat) -> UIBezierPath {
        let startPadding = size * START_PADDING_SCALE
        let endPadding = size * END_PADDING_SCALE

        let startPoint = CGPointMake(size - startPadding, size/2)
        let endPoint = CGPointMake(endPadding, size/2)

        return UIBezierPath.arrow(size - startPadding - endPadding, from: startPoint, to: endPoint)
    }

    class func rightArrow(size: CGFloat) -> UIBezierPath {
        let startPadding = size * START_PADDING_SCALE
        let endPadding = size * END_PADDING_SCALE

        let startPoint = CGPointMake(startPadding, size/2)
        let endPoint = CGPointMake(size - endPadding, size/2)


        return UIBezierPath.arrow(size - startPadding - endPadding, from: startPoint, to: endPoint)
    }

    class func circle(size: CGFloat) -> UIBezierPath {
        return UIBezierPath(
        arcCenter: CGPoint(x: size / 2, y: size / 2),
                radius: CGFloat(size / 2),
                startAngle: CGFloat(0),
                endAngle:CGFloat(M_PI * 2),
                clockwise: true
        )
    }

}
