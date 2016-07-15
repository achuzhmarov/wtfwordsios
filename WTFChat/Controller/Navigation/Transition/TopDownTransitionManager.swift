import UIKit

class TopDownTransitionManager: BaseTransitionManager  {

    private var offScreenBack: CGAffineTransform!
    private var offScreenForward: CGAffineTransform!

    override func preAnimate() {
        offScreenBack = CGAffineTransformMakeTranslation(0, -container.frame.height)
        offScreenForward = CGAffineTransformMakeTranslation(0, container.frame.height)

        // prepare the toView for the animation
        toView.transform = presenting ? offScreenBack : offScreenForward
    }

    override func animate() {
        // slide fromView off either the left or right edge of the screen
        // depending if we're presenting or dismissing this view
        fromView.transform = presenting ? offScreenForward : offScreenBack
        toView.transform = CGAffineTransformIdentity
    }

    override func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return 0.5
    }
}
