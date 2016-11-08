import UIKit

class TopDownTransitionManager: BaseTransitionManager  {

    fileprivate var offScreenBack: CGAffineTransform!
    fileprivate var offScreenForward: CGAffineTransform!

    override func preAnimate() {
        offScreenBack = CGAffineTransform(translationX: 0, y: -container.frame.height)
        offScreenForward = CGAffineTransform(translationX: 0, y: container.frame.height)

        // prepare the toView for the animation
        toView.transform = presenting ? offScreenBack : offScreenForward
    }

    override func animate() {
        // slide fromView off either the left or right edge of the screen
        // depending if we're presenting or dismissing this view
        fromView.transform = presenting ? offScreenForward : offScreenBack
        toView.transform = CGAffineTransform.identity
    }
}
