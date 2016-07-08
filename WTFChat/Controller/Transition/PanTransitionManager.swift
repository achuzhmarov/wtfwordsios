import UIKit

class PanTransitionManager: BaseTransitionManager  {

    private var offScreenBack: CGAffineTransform!
    private var offScreenForward: CGAffineTransform!

    var unwindSegue: (() -> Void)!

    func handleOffstagePan(pan: UIPanGestureRecognizer){
        let translation = pan.translationInView(pan.view!.superview!)
        let d = -translation.y / CGRectGetHeight(pan.view!.superview!.frame)

        switch (pan.state) {

        case UIGestureRecognizerState.Began:
            interactive = true
            unwindSegue()
            break
        case UIGestureRecognizerState.Changed:
            updateInteractiveTransition(d)
            break
        default: // .Ended, .Cancelled, .Failed ...
            interactive = false

            if(d > 0.15){
                self.finishInteractiveTransition()
            }
            else {
                self.cancelInteractiveTransition()
            }
        }
    }

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
}
