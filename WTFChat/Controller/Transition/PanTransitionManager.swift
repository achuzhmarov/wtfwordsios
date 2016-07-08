import UIKit

class PanTransitionManager: UIPercentDrivenInteractiveTransition,
        UIViewControllerAnimatedTransitioning, UIViewControllerTransitioningDelegate  {

    private var presenting = true
    private var interactive = false

    var unwindSegue: (() -> Void)!

    func handleOffstagePan(pan: UIPanGestureRecognizer){
        let translation = pan.translationInView(pan.view!.superview!)
        let d = -translation.y / CGRectGetHeight(pan.view!.superview!.frame)

        switch (pan.state) {

        case UIGestureRecognizerState.Began:
            self.interactive = true
            unwindSegue()
            break

        case UIGestureRecognizerState.Changed:
            self.updateInteractiveTransition(d)
            break

        default: // .Ended, .Cancelled, .Failed ...
            self.interactive = false
            if(d > 0.2){
                self.finishInteractiveTransition()
            }
            else {
                self.cancelInteractiveTransition()
            }
        }
    }

    // MARK: UIViewControllerAnimatedTransitioning protocol methods

    // animate a change from one viewcontroller to another
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        // get reference to our fromView, toView and the container view that we should perform the transition in
        let container = transitionContext.containerView()!
        let screens : (from:UIViewController, to:UIViewController) = (
            transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)!,
            transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)!
        )

        let toView = screens.to.view
        let fromView = screens.from.view

        // fix for bug in iOS 9 - if rotated after transition
        toView.frame.size = transitionContext.finalFrameForViewController(screens.to).size
        (screens.to as! BaseUIViewController).updateBackgroundGradient(toView.frame.size)

        let offScreenBack = CGAffineTransformMakeTranslation(0, -container.frame.height)
        let offScreenForward = CGAffineTransformMakeTranslation(0, container.frame.height)

        // prepare the toView for the animation
        toView.transform = self.presenting ? offScreenBack : offScreenForward

        // add the both views to our view controller
        container.addSubview(toView)
        container.addSubview(fromView)

        let duration = self.transitionDuration(transitionContext)

        UIView.animateWithDuration(duration, delay: 0, options: [], animations: {
            // slide fromView off either the left or right edge of the screen
            // depending if we're presenting or dismissing this view
            fromView.transform = self.presenting ? offScreenForward : offScreenBack
            toView.transform = CGAffineTransformIdentity

        }, completion: { finished in

            // tell our transitionContext object that we've finished animating
            if(transitionContext.transitionWasCancelled()){
                transitionContext.completeTransition(false)
                // bug: we have to manually add our 'to view' back http://openradar.appspot.com/radar?id=5320103646199808
                UIApplication.sharedApplication().keyWindow!.addSubview(screens.from.view)
            }
            else {
                transitionContext.completeTransition(true)
                // bug: we have to manually add our 'to view' back http://openradar.appspot.com/radar?id=5320103646199808
                UIApplication.sharedApplication().keyWindow!.addSubview(screens.to.view)
            }
        })

    }

    // return how many seconds the transiton animation will take
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return 0.5
    }

    // MARK: UIViewControllerTransitioningDelegate protocol methods

    // return the animataor when presenting a viewcontroller
    // rememeber that an animator (or animation controller) is any object that aheres to the UIViewControllerAnimatedTransitioning protocol
    func animationControllerForPresentedController(presented: UIViewController,
                                                   presentingController presenting: UIViewController,
                                                   sourceController source: UIViewController
    ) -> UIViewControllerAnimatedTransitioning? {
        self.presenting = true
        return self
    }

    // return the animator used when dismissing from a viewcontroller
    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        self.presenting = false
        return self
    }

    func interactionControllerForPresentation(animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        // if our interactive flag is true, return the transition manager object
        // otherwise return nil
        return self.interactive ? self : nil
    }

    func interactionControllerForDismissal(animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return self.interactive ? self : nil
    }
}
